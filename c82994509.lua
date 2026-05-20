--ツクシー
-- 效果：
-- 这张卡被战斗破坏送去墓地时，在对方场上把1只「笔头菜衍生物」（植物族·风·1星·攻/守0）守备表示特殊召唤。这衍生物被和植物族怪兽的战斗破坏的场合，这衍生物的控制者把1张手卡送去墓地。
function c82994509.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，在对方场上把1只「笔头菜衍生物」（植物族·风·1星·攻/守0）守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82994509,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c82994509.condition)
	e1:SetTarget(c82994509.target)
	e1:SetOperation(c82994509.operation)
	c:RegisterEffect(e1)
end
-- 检查自身是否被战斗破坏并送去墓地
function c82994509.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果发动的目标处理，设置产生衍生物和特殊召唤的操作信息
function c82994509.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示此效果会产生衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表示此效果会进行特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理，在对方场上特殊召唤「笔头菜衍生物」并为其注册离场时丢弃手卡的效果
function c82994509.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否有可用的怪兽区域空位
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	-- 检查是否可以特殊召唤指定的「笔头菜衍生物」到对方场上
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,82994510,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_PLANT,ATTRIBUTE_WIND,POS_FACEUP_DEFENSE,1-tp) then return end
	-- 创建「笔头菜衍生物」的卡片数据
	local token=Duel.CreateToken(tp,82994510)
	-- 尝试将衍生物以表侧守备表示特殊召唤到对方场上
	if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这衍生物被和植物族怪兽的战斗破坏的场合，这衍生物的控制者把1张手卡送去墓地。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetOperation(c82994509.handop)
		token:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
-- 衍生物离场时的效果处理，若因与植物族怪兽战斗破坏，则让其控制者将1张手卡送去墓地
function c82994509.handop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE) and c:GetBattleTarget():IsRace(RACE_PLANT) then
		-- 向玩家发送提示信息，要求选择送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让衍生物原本的控制者选择并丢弃1张手卡送去墓地
		Duel.DiscardHand(c:GetPreviousControler(),nil,1,1,REASON_EFFECT)
	end
	e:Reset()
end
