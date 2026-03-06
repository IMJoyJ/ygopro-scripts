--E・HERO サンライザー
-- 效果：
-- 属性不同的「英雄」怪兽×2
-- 这张卡不用融合召唤不能特殊召唤。这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「奇迹融合」加入手卡。
-- ②：自己场上的怪兽的攻击力上升自己场上的怪兽的属性种类×200。
-- ③：其他的自己的「英雄」怪兽进行战斗的攻击宣言时，以场上1张卡为对象才能发动。那张卡破坏。
function c22908820.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤条件，需要使用2个满足过滤条件的「英雄」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,c22908820.ffilter,2,true)
	-- 这张卡不用融合召唤不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡的特殊召唤条件为必须通过融合召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 从卡组把1张「奇迹融合」加入手卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22908820,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,22908820)
	e2:SetTarget(c22908820.srtg)
	e2:SetOperation(c22908820.srop)
	c:RegisterEffect(e2)
	-- 自己场上的怪兽的攻击力上升自己场上的怪兽的属性种类×200
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetValue(c22908820.val)
	c:RegisterEffect(e3)
	-- 其他的自己的「英雄」怪兽进行战斗的攻击宣言时，以场上1张卡为对象才能发动。那张卡破坏
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(22908820,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,22908821)
	e4:SetCondition(c22908820.descon)
	e4:SetTarget(c22908820.destg)
	e4:SetOperation(c22908820.desop)
	c:RegisterEffect(e4)
end
c22908820.material_setcode=0x8
-- 融合素材过滤函数，确保融合素材中不包含重复属性的怪兽
function c22908820.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x8) and (not sg or not sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- 检索过滤函数，用于筛选「奇迹融合」卡
function c22908820.srfilter(c)
	return c:IsCode(45906428) and c:IsAbleToHand()
end
-- 设置效果发动时的检索条件，检查卡组中是否存在「奇迹融合」
function c22908820.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「奇迹融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c22908820.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果发动时的操作信息，表示将从卡组检索1张「奇迹融合」加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并把「奇迹融合」加入手牌
function c22908820.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「奇迹融合」卡
	local g=Duel.SelectMatchingCard(tp,c22908820.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 攻击力计算过滤函数，筛选场上正面表示的非属性怪兽
function c22908820.atkfilter(c)
	return c:IsFaceup() and c:GetAttribute()~=0
end
-- 计算场上怪兽属性种类数并乘以200作为攻击力加成
function c22908820.val(e,c)
	-- 获取场上所有正面表示的怪兽
	local g=Duel.GetMatchingGroup(c22908820.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	-- 返回场上怪兽属性种类数乘以200的攻击力加成
	return aux.GetAttributeCount(g)*200
end
-- 攻击宣言时的条件判断函数，确保攻击怪兽是自己的「英雄」怪兽
function c22908820.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前攻击怪兽
	local ac=Duel.GetAttacker()
	-- 获取当前攻击目标
	local tc=Duel.GetAttackTarget()
	if not ac:IsControler(tp) then ac,tc=tc,ac end
	return ac and ac:IsControler(tp) and ac:IsFaceup() and ac:IsSetCard(0x8) and ac~=c
end
-- 设置破坏效果的目标选择条件，选择场上任意一张卡
function c22908820.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可破坏的目标
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张卡作为破坏目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果发动时的操作信息，表示将破坏1张场上卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，破坏选中的卡
function c22908820.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
