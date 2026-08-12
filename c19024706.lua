--ヒーロー逆襲
-- 效果：
-- 自己场上存在的名字带有「元素英雄」的怪兽被战斗破坏时才能发动。从自己手卡对方随机选择1张卡。那张是名字带有「元素英雄」的怪兽卡的场合，对方场上1只怪兽破坏，并把选择的卡在自己场上特殊召唤。
function c19024706.initial_effect(c)
	-- 效果设置：将此卡注册为发动时点为战斗破坏的魔法卡，条件为己方场上存在名字带有「元素英雄」的怪兽被战斗破坏，目标为对方场上1只怪兽破坏并特殊召唤手卡中的「元素英雄」怪兽卡
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c19024706.condition)
	e1:SetTarget(c19024706.target)
	e1:SetOperation(c19024706.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查目标怪兽是否为名字带有「元素英雄」的怪兽且上一个控制者为指定玩家
function c19024706.cfilter(c,tp)
	return c:IsSetCard(0x3008) and c:IsPreviousControler(tp)
end
-- 效果条件：确认被战斗破坏的怪兽中存在名字带有「元素英雄」且上一个控制者为自己的怪兽
function c19024706.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19024706.cfilter,1,nil,tp)
end
-- 效果目标：确认己方手卡中存在名字带有「元素英雄」的怪兽卡
function c19024706.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果目标：确认己方手卡中存在名字带有「元素英雄」的怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND,0,1,nil,0x3008) end
end
-- 效果发动：从己方手卡中随机选择一张卡，若该卡为名字带有「元素英雄」的怪兽卡，则破坏对方场上1只怪兽并特殊召唤该卡
function c19024706.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手卡：获取己方手卡中的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local sg=g:RandomSelect(1-tp,1)
	local tc=sg:GetFirst()
	if tc then
		-- 确认卡片：向对方玩家确认所选卡片内容
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsSetCard(0x3008) and tc:IsType(TYPE_MONSTER) then
			-- 提示选择：提示己方玩家选择要破坏的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择破坏目标：选择对方场上1只怪兽作为破坏目标
			local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
			-- 破坏怪兽：以效果原因破坏所选怪兽
			Duel.Destroy(dg,REASON_EFFECT)
			-- 特殊召唤：尝试将所选怪兽特殊召唤到己方场上，若失败则洗切手卡
			if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then
				-- 洗切手卡：将己方手卡洗切
				Duel.ShuffleHand(tp)
			end
		else
			-- 洗切手卡：将己方手卡洗切
			Duel.ShuffleHand(tp)
		end
	end
end
