--E・HERO サンライザー
-- 效果：
-- 属性不同的「英雄」怪兽×2
-- 这张卡不用融合召唤不能特殊召唤。这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「奇迹融合」加入手卡。
-- ②：自己场上的怪兽的攻击力上升自己场上的怪兽的属性种类×200。
-- ③：其他的自己的「英雄」怪兽进行战斗的攻击宣言时，以场上1张卡为对象才能发动。那张卡破坏。
function c22908820.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：用2只满足ffilter条件的怪兽作为融合素材，即“属性不同的「英雄」怪兽×2”。
	aux.AddFusionProcFunRep(c,c22908820.ffilter,2,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将该特殊召唤限制效果的值设为aux.fuslimit，使其只在通过融合召唤方式特殊召唤时才被允许。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「奇迹融合」加入手卡。
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
	-- ②：自己场上的怪兽的攻击力上升自己场上的怪兽的属性种类×200。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetValue(c22908820.val)
	c:RegisterEffect(e3)
	-- ③：其他的自己的「英雄」怪兽进行战斗的攻击宣言时，以场上1张卡为对象才能发动。那张卡破坏。
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
-- 融合素材过滤函数：素材必须为「英雄」怪兽，且与已选素材的属性互不相同，从而满足“属性不同的「英雄」怪兽×2”。
function c22908820.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x8) and (not sg or not sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- 检索过滤函数：从卡组中选出卡号为45906428的「奇迹融合」，且该卡可以加入手牌。
function c22908820.srfilter(c)
	return c:IsCode(45906428) and c:IsAbleToHand()
end
-- 效果①的发动条件和目标设定：若特殊召唤成功的场合，且自己卡组有可加入手牌的「奇迹融合」则可发动；发动时设置检索1张卡到手的操作信息。
function c22908820.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时判断卡组是否存在至少1张符合条件的「奇迹融合」，满足条件才允许发动效果①。
	if chk==0 then return Duel.IsExistingMatchingCard(c22908820.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为：效果处理时从自己卡组把1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的实际处理操作：从卡组选择1张「奇迹融合」加入手牌，并向对手展示确认。
function c22908820.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动者显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动者从自己卡组选择1张满足srfilter条件的「奇迹融合」。
	local g=Duel.SelectMatchingCard(tp,c22908820.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手牌，原因记为效果处理（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认加入手牌的那张卡，以满足确认公开信息的需要。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 攻击力上升的统计过滤函数：选取自己场上表侧表示且属性不为0（有属性）的怪兽。
function c22908820.atkfilter(c)
	return c:IsFaceup() and c:GetAttribute()~=0
end
-- 效果②的数值函数：统计自己场上符合条件的怪兽中的属性种类数，并乘以200作为攻击力上升量。
function c22908820.val(e,c)
	-- 取得自己场上（主要怪兽区或额外怪兽区）所有满足atkfilter条件的表侧表示怪兽。
	local g=Duel.GetMatchingGroup(c22908820.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	-- 返回“属性种类数×200”，供永续效果更新自己场上怪兽的攻击力。
	return aux.GetAttributeCount(g)*200
end
-- 效果③的发动条件：当其他自己的表侧表示「英雄」怪兽进行攻击宣言时，可以发动（该怪兽不能是本卡自身）。
function c22908820.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前攻击宣言的攻击怪兽。
	local ac=Duel.GetAttacker()
	-- 取得当前攻击宣言的攻击对象怪兽，用于调整攻击者为己方怪兽的情况。
	local tc=Duel.GetAttackTarget()
	if not ac:IsControler(tp) then ac,tc=tc,ac end
	return ac and ac:IsControler(tp) and ac:IsFaceup() and ac:IsSetCard(0x8) and ac~=c
end
-- 效果③的目标处理：选择场上1张卡作为破坏对象，并设置破坏操作信息。
function c22908820.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- chk==0时检查场上是否存在至少1张可以作为效果对象的卡，存在才能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向发动者显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动者从场上选择1张卡作为对象，并自动将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为：破坏所选择的1张对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果③的实际处理：取得对象卡，若该卡仍与效果相关，则将其破坏。
function c22908820.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果③发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
