--見えざる手ダンダロス
-- 效果：
-- 「不可见之手」怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以对方场上1只怪兽为对象才能发动。得到那只怪兽的控制权。
-- ②：只要这张卡在怪兽区域存在，自己的「不可见之手」融合怪兽以及原本持有者是对方的自己怪兽可以直接攻击。
-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
local s,id,o=GetID()
-- 注册这张卡的融合召唤手续、苏生限制以及三个效果：用2只『不可见之手』怪兽为素材的融合召唤手续；①以对方场上1只怪兽为对象发动并获得其控制权（1回合1次）；②自己的『不可见之手』融合怪兽和原本持有者为对方的己方怪兽可直接攻击；③这张卡与怪兽战斗时那2只不会被战斗破坏。
function s.initial_effect(c)
	-- 为这张卡添加融合召唤手续：使用2只满足『持有『不可见之手』字段』条件的怪兽作为融合素材即可进行融合召唤。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1d3),2,true)
	c:EnableReviveLimit()
	-- 对应效果原文：这个卡名的①的效果1回合只能使用1次。①：以对方场上1只怪兽为对象才能发动。得到那只怪兽的控制权。
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
	-- 对应效果原文：②：只要这张卡在怪兽区域存在，自己的『不可见之手』融合怪兽以及原本持有者是对方的自己怪兽可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.datg)
	c:RegisterEffect(e2)
	-- 对应效果原文：③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- ①效果的对象选择与发动条件：在对方怪兽区选择1只可变更控制权的怪兽为对象；若存在则发动，并登记『获得控制权』的操作信息。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 发动条件判定：检查对方场上怪兽区是否存在至少1只满足控制权可被变更的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 向己方玩家显示选择提示，要求选择1只要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方怪兽区选择1只符合条件的怪兽作为效果对象，并自动与本次连锁建立联系。
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将本次效果要获得控制权的操作信息写入当前连锁，供其他卡的发动条件检测使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- ①效果处理：获得效果对象怪兽的控制权。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁上记录的对象怪兽（发动效果时选择的那1只怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将对象怪兽的控制权转移给己方玩家。
		Duel.GetControl(tc,tp)
	end
end
-- 直接攻击效果的适用对象判定：若怪兽是『不可见之手』融合怪兽，或原本持有者为对方的己方怪兽，则允许其直接攻击。
function s.datg(e,c)
	return c:IsSetCard(0x1d3) and c:IsType(TYPE_FUSION) or c:GetOwner()~=e:GetHandlerPlayer()
end
-- 战斗破坏耐性对象判定：保护这张卡自身以及这张卡的战斗对象，使其不受那次战斗破坏。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
