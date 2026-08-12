--EMミス・ディレクター
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要自己场上有「异色眼」怪兽存在，对方不能选择这张卡作为攻击对象。
-- ②：只要这张卡在怪兽区域守备表示存在，自己的「异色眼」怪兽不会被战斗破坏，那次战斗发生的对自己的战斗伤害变成0。
-- ③：以自己墓地1只1星怪兽为对象才能发动。那只怪兽效果无效特殊召唤，只用那只怪兽和这张卡为素材作同调召唤。
function c92932860.initial_effect(c)
	-- ①：只要自己场上有「异色眼」怪兽存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c92932860.atcon)
	-- 设置不能成为攻击对象效果的过滤函数
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域守备表示存在，自己的「异色眼」怪兽不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的目标为自己场上的「异色眼」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x99))
	e2:SetCondition(c92932860.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 那次战斗发生的对自己的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置伤害变0效果影响的目标为自己场上的「异色眼」怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x99))
	e3:SetCondition(c92932860.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：以自己墓地1只1星怪兽为对象才能发动。那只怪兽效果无效特殊召唤，只用那只怪兽和这张卡为素材作同调召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,92932860)
	e4:SetTarget(c92932860.sctg)
	e4:SetOperation(c92932860.scop)
	c:RegisterEffect(e4)
end
-- 过滤条件：表侧表示的「异色眼」怪兽
function c92932860.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x99)
end
-- 攻击限制效果的发动条件：自己场上存在「异色眼」怪兽
function c92932860.atcon(e)
	-- 检查自己场上是否存在表侧表示的「异色眼」怪兽
	return Duel.IsExistingMatchingCard(c92932860.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 战斗破坏抗性和伤害变0效果的发动条件：这张卡在怪兽区域守备表示存在
function c92932860.indcon(e)
	return e:GetHandler():IsDefensePos()
end
-- 过滤条件：墓地中可以特殊召唤的1星怪兽，且能与这张卡作为素材进行同调召唤
function c92932860.scfilter1(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组是否存在能以墓地怪兽和这张卡为素材进行同调召唤的怪兽
		and Duel.IsExistingMatchingCard(c92932860.scfilter2,tp,LOCATION_EXTRA,0,1,nil,mg)
end
-- 过滤条件：可以使用指定素材进行同调召唤的怪兽
function c92932860.scfilter2(c,mg)
	return c:IsSynchroSummonable(nil,mg)
end
-- 同调召唤效果的发动准备（Target函数）
function c92932860.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c92932860.scfilter1(chkc,e,tp,c) end
	-- 检查玩家是否能进行2次特殊召唤（特殊召唤墓地怪兽和同调召唤）
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查自己场上是否有可用的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在符合条件的1星怪兽作为效果对象
		and Duel.IsExistingTarget(c92932860.scfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,c) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只符合条件的1星怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c92932860.scfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,c)
	-- 设置操作信息：特殊召唤2只怪兽（包含从额外卡组特殊召唤）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,tp,LOCATION_EXTRA)
end
-- 同调召唤效果的执行逻辑（Operation函数）
function c92932860.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域空格，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取选中的墓地1星怪兽对象
	local tc=Duel.GetFirstTarget()
	-- 若对象卡已不关联效果，或特殊召唤失败，则不继续处理
	if not tc:IsRelateToEffect(e) or not Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then return end
	-- 那只怪兽效果无效特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	tc:RegisterEffect(e2)
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
	if not c:IsRelateToEffect(e) then return end
	-- 刷新场地信息，确保怪兽状态和等级等数据更新
	Duel.AdjustAll()
	local mg=Group.FromCards(c,tc)
	if mg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 获取额外卡组中可以使用这两只怪兽作为素材进行同调召唤的怪兽组
	local g=Duel.GetMatchingGroup(c92932860.scfilter2,tp,LOCATION_EXTRA,0,nil,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要同调召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 使用这两只怪兽作为素材，对选中的怪兽进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
