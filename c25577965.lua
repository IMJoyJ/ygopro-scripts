--炎魔刃フレイムタン
-- 效果：
-- 炎属性怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己场上的表侧表示的魔法·陷阱卡不会被对方的效果破坏。
-- ②：以自己的除外状态的1只炎属性怪兽为对象才能发动。那只怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
local s,id,o=GetID()
-- 初始化卡片效果：设定苏生限制和炎属性连接素材条件，注册①的保护己方表侧魔法·陷阱卡不被对方效果破坏的永续效果，以及②的取对象回手并自肃的起动效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡设置连接召唤手续：必须且只能用2只炎属性怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_FIRE),2,2)
	-- ①：只要这张卡在怪兽区域存在，自己场上的表侧表示的魔法·陷阱卡不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	-- 设置①效果的保护对象为魔法·陷阱卡，并配合SetTargetRange限定为己方场上的卡。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SPELL+TYPE_TRAP))
	-- 使用aux.indoval将①效果的破坏免疫限定为只针对对方发动的效果，从而实现‘不会被对方的效果破坏’。
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：以自己的除外状态的1只炎属性怪兽为对象才能发动。那只怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 定义②的对象筛选函数：必须是表侧表示、炎属性且能够加入手卡的怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- ②的发动处理：在己方除外区选择1只符合条件的炎属性怪兽作为对象，并登记回手牌操作信息；同时负责发动条件检查。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 在发动条件检查（chk==0）阶段，确认己方除外区至少存在1只满足s.filter的炎属性怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向操作者显示‘请选择要加入手牌的卡’的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从己方除外区选择1只满足s.filter的炎属性怪兽，并将其登记为连锁处理的对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 登记操作信息：声明本次效果会包含将1张卡加入手牌，供其他卡的发动时机检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②的解决处理：将对象怪兽加入手牌；若加入成功并且该卡确实在手牌，则给自己附加本回合不能发动该卡及同名卡效果的封锁。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断对象仍与该效果关联，且将其加入手牌成功并位于手牌后，才继续附加同名卡效果发动限制。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetLabel(tc:GetCode())
		e1:SetValue(s.limit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将禁止同名卡效果发动的封锁效果注册给当前玩家，持续到结束阶段。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 封锁效果的判定：若某效果的发动者卡号与记录的卡号相同（即被加入手卡的卡及其同名卡），则禁止其发动。
function s.limit(e,re,rp)
	return re:GetHandler():IsCode(e:GetLabel())
end
