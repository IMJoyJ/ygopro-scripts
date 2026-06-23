--見えざる手ダンダロス
-- 效果：
-- 「不可见之手」怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以对方场上1只怪兽为对象才能发动。得到那只怪兽的控制权。
-- ②：只要这张卡在怪兽区域存在，自己的「不可见之手」融合怪兽以及原本持有者是对方的自己怪兽可以直接攻击。
-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合召唤条件、苏生限制及三个效果
function s.initial_effect(c)
	-- 设置融合召唤条件为2个「不可见之手」融合怪兽
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1d3),2,true)
	c:EnableReviveLimit()
	-- ①：以对方场上1只怪兽为对象才能发动。得到那只怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"获取控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己的「不可见之手」融合怪兽以及原本持有者是对方的自己怪兽可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.datg)
	c:RegisterEffect(e2)
	-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 设置控制权变更效果的目标选择函数
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 判断是否满足控制权变更效果的发动条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上的1只可以改变控制权的怪兽作为目标
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，确定将要改变控制权的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 控制权变更效果的处理函数
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标怪兽的控制权转移给发动玩家
		Duel.GetControl(tc,tp)
	end
end
-- 设置直接攻击效果的目标判断函数
function s.datg(e,c)
	return c:IsSetCard(0x1d3) and c:IsType(TYPE_FUSION) or c:GetOwner()~=e:GetHandlerPlayer()
end
-- 设置战斗不会被破坏效果的目标判断函数
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
