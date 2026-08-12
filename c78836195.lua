--瑞相剣究
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。从自己墓地把最多5张「相剑」卡或者幻龙族怪兽除外，作为对象的怪兽的攻击力上升除外数量×300。
-- ②：这张卡被除外的场合才能发动。在自己场上把1只「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
function c78836195.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。从自己墓地把最多5张「相剑」卡或者幻龙族怪兽除外，作为对象的怪兽的攻击力上升除外数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,78836195)
	-- 设置效果在伤害步骤中除伤害计算时以外可以发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c78836195.target)
	e1:SetOperation(c78836195.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合才能发动。在自己场上把1只「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78836195,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,78836196)
	e2:SetTarget(c78836195.sptg)
	e2:SetOperation(c78836195.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地的「相剑」卡或幻龙族怪兽，且可以被除外
function c78836195.filter(c)
	return (c:IsSetCard(0x16b) or (c:IsType(TYPE_MONSTER) and c:IsRace(RACE_WYRM))) and c:IsAbleToRemove()
end
-- 效果①的发动准备与目标选择
function c78836195.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		-- 并且自己墓地存在至少1张满足过滤条件的卡
		and Duel.IsExistingMatchingCard(c78836195.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的处理过程
function c78836195.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取自己墓地所有满足过滤条件的卡
	local g=Duel.GetMatchingGroup(c78836195.filter,tp,LOCATION_GRAVE,0,nil)
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and g:GetCount()>0 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(tp,1,5,nil)
		-- 将选择的卡表侧表示除外，并获取实际除外的卡片数量
		local rc=Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		-- 作为对象的怪兽的攻击力上升除外数量×300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(300*rc)
		tc:RegisterEffect(e1)
	end
end
-- 效果②的发动准备与特殊召唤判定
function c78836195.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查玩家是否可以特殊召唤指定的相剑衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20001444,0x16b,TYPES_TOKEN_MONSTER,0,0,4,RACE_WYRM,ATTRIBUTE_WATER) end
	-- 设置效果处理信息：包含产生衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置效果处理信息：包含特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果②的处理过程
function c78836195.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查自己场上是否有可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且再次检查玩家是否可以特殊召唤指定的相剑衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20001444,0x16b,TYPES_TOKEN_MONSTER,0,0,4,RACE_WYRM,ATTRIBUTE_WATER) then
		-- 在后台创建相剑衍生物卡片
		local token=Duel.CreateToken(tp,78836196)
		-- 将衍生物以表侧表示特殊召唤到场上（单步处理）
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c78836195.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
	end
end
-- 限制只能从额外卡组特殊召唤同调怪兽的过滤函数
function c78836195.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
