--クロス・デバッガー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有连接怪兽2只以上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己和对方的连接怪兽之间进行战斗的伤害计算时，把墓地的这张卡除外，以自己墓地1只连接怪兽为对象才能发动。那只进行战斗的自己怪兽的攻击力直到回合结束时上升作为对象的怪兽的攻击力数值，不会被那次战斗破坏。
function c9097866.initial_effect(c)
	-- ①：自己场上有连接怪兽2只以上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9097866,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,9097866)
	e1:SetCondition(c9097866.spcon)
	e1:SetTarget(c9097866.sptg)
	e1:SetOperation(c9097866.spop)
	c:RegisterEffect(e1)
	-- ②：自己和对方的连接怪兽之间进行战斗的伤害计算时，把墓地的这张卡除外，以自己墓地1只连接怪兽为对象才能发动。那只进行战斗的自己怪兽的攻击力直到回合结束时上升作为对象的怪兽的攻击力数值，不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9097866,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,9097867)
	e2:SetCondition(c9097866.atkcon)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c9097866.atktg)
	e2:SetOperation(c9097866.atkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的连接怪兽
function c9097866.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 效果①的发动条件：自己场上有2只以上的连接怪兽存在
function c9097866.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少2只表侧表示的连接怪兽
	return Duel.IsExistingMatchingCard(c9097866.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 效果①的发动准备：检查怪兽区域空位以及自身是否可以特殊召唤
function c9097866.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将这张卡从手卡特殊召唤
function c9097866.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的发动条件：自己和对方的连接怪兽之间进行战斗的伤害计算时
function c9097866.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	e:SetLabelObject(a)
	return a and d and a:IsRelateToBattle() and d:IsRelateToBattle() and a:IsType(TYPE_LINK) and d:IsType(TYPE_LINK)
end
-- 过滤条件：墓地的连接怪兽且攻击力在0以上
function c9097866.atkfilter(c)
	return c:IsType(TYPE_LINK) and c:IsAttackAbove(0)
end
-- 效果②的发动准备：检查并选择自己墓地1只连接怪兽作为对象
function c9097866.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c9097866.atkfilter(chkc) end
	-- 检查自己墓地是否存在除这张卡以外的、满足条件的连接怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c9097866.atkfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1只连接怪兽作为效果的对象
	Duel.SelectTarget(tp,c9097866.atkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
end
-- 效果②的效果处理：使进行战斗的自己怪兽攻击力上升，且不会被那次战斗破坏
function c9097866.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=e:GetLabelObject()
	-- 获取作为效果对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	if a:IsFaceup() and a:IsRelateToBattle() and tc:IsRelateToEffect(e) then
		-- 那只进行战斗的自己怪兽的攻击力直到回合结束时上升作为对象的怪兽的攻击力数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		a:RegisterEffect(e1)
		-- 不会被那次战斗破坏
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		a:RegisterEffect(e2)
	end
end
