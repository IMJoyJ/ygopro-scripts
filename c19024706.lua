--ヒーロー逆襲
-- 效果：
-- 自己场上存在的名字带有「元素英雄」的怪兽被战斗破坏时才能发动。从自己手卡对方随机选择1张卡。那张是名字带有「元素英雄」的怪兽卡的场合，对方场上1只怪兽破坏，并把选择的卡在自己场上特殊召唤。
function c19024706.initial_effect(c)
	-- 自己场上存在的名字带有「元素英雄」的怪兽被战斗破坏时才能发动。从自己手卡对方随机选择1张卡。那张是名字带有「元素英雄」的怪兽卡的场合，对方场上1只怪兽破坏，并把选择的卡在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c19024706.condition)
	e1:SetTarget(c19024706.target)
	e1:SetOperation(c19024706.activate)
	c:RegisterEffect(e1)
end
-- 判定卡片的筛选条件：该卡是名字带有「元素英雄」的怪兽，且被战斗破坏之前由tp控制（即tp场上存在的元素英雄怪兽）。
function c19024706.cfilter(c,tp)
	return c:IsSetCard(0x3008) and c:IsPreviousControler(tp)
end
-- 触发条件：战斗破坏送去墓地的怪兽组eg中存在至少1只满足c19024706.cfilter的怪兽，也就是自己场上的元素英雄怪兽被战斗破坏。
function c19024706.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19024706.cfilter,1,nil,tp)
end
-- 发动时点判定：确认自己手卡中是否存在至少1张名字带有「元素英雄」的卡，满足“从自己手卡随机选择1张”的前提。
function c19024706.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时（chk==0）检查自己手卡是否至少有1张名字带有「元素英雄」的卡，以此作为效果能否发动的合法性条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND,0,1,nil,0x3008) end
end
-- 效果处理流程：从自己手卡随机选1张卡给对方确认；若该卡是名字带有「元素英雄」的怪兽，则破坏对方场上1只怪兽并将该卡特殊召唤到自己场上，否则只洗切手卡。
function c19024706.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手卡中的全部卡，作为对方随机选择1张卡的选择范围。
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local sg=g:RandomSelect(1-tp,1)
	local tc=sg:GetFirst()
	if tc then
		-- 将随机选出的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsSetCard(0x3008) and tc:IsType(TYPE_MONSTER) then
			-- 弹出“请选择要破坏的卡”的选择提示，用于后续选择对方场上的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 从对方场上（LOCATION_MZONE）选择1只怪兽（不取对象，效果处理时选择）作为将要破坏的卡。
			local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
			-- 将选择的对方怪兽以效果原因破坏。
			Duel.Destroy(dg,REASON_EFFECT)
			-- 将随机选中的那张卡以表侧表示特殊召唤到自己场上；若特殊召唤成功数量为0（未能特殊召唤），则执行洗切手卡。
			if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then
				-- 当特殊召唤失败时，洗切手卡以恢复手卡原顺序。
				Duel.ShuffleHand(tp)
			end
		else
			-- 当随机选出的卡不是元素英雄怪兽时，洗切手卡以恢复手卡原顺序。
			Duel.ShuffleHand(tp)
		end
	end
end
