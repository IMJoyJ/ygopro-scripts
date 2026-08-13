--EM：Pグレニャード
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：场上或者自己或对方的墓地有连接怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡在手卡·墓地存在，自己场上的连接2怪兽被送去墓地的场合或者被表侧除外的场合，把这张卡除外，以对方场上1张卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 注册卡片的全部效果：为这张卡添加“已在墓地”检查标记；注册①效果作为手卡规则特殊召唤（带1回合1次的誓约次数限制）；注册②效果作为诱发效果，在自己场上的连接2怪兽被送去墓地时除外自身并选对方场上1张卡返回手牌；再克隆出一个相同效果并改为除外时触发，二者共同构成②效果且共享1回合1次限制。
function s.initial_effect(c)
	-- 为这张卡注册一个“此卡已在墓地”的标记检测效果，用于记录卡片进入过墓地的状态，防止在同一连锁中进行不合规的重复判定，供后续②效果判断“手卡·墓地”的发动条件使用。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己或对方的场上或墓地有连接怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上的连接2怪兽被送去墓地的场合或者被表侧除外的场合，把手卡·墓地的这张卡除外，以对方场上1张卡为对象才能发动。那张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+1)
	e2:SetLabelObject(e0)
	-- 设置②效果的发动代价：把发动效果的那张卡（手卡·墓地的这张卡）自身除外，由通用代价函数aux.bfgcost完成。
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
-- 定义①效果的特殊召唤条件：当c为nil时返回true表示允许适用特殊召唤手续；否则要求这张卡的控制者场上有主要怪兽区空位，并且双方场上或墓地存在连接怪兽，才能从手卡特殊召唤。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查这张卡的控制者场上是否存在可用的主要怪兽区空格（特殊召唤所需的空位）。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查以控制者为准的双方场上或墓地是否存在至少1只连接怪兽（TYPE_LINK），满足①效果的召唤条件。
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil,TYPE_LINK)
end
-- 过滤函数：判断一只怪兽是否属于“自己场上的连接2怪兽被送去墓地或者被表侧除外”——它之前位于主要怪兽区、连接标记为2、不是由指定效果se导致移动、当前在墓地或表侧除外、且原控制者是这张卡的控制者。
function s.cfilter(c,tp,se)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLink(2) and (se==nil or c:GetReasonEffect()~=se)
		and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup())) and c:IsPreviousControler(tp)
end
-- ②效果的发动条件：本次发生送墓/除外的怪兽组eg中存在满足s.cfilter的怪兽，即自己场上的连接2怪兽被送去墓地或表侧除外；其中se从标记效果的LabelObject中取得，用于排除特定效果导致的移动，防止重复触发。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,tp,se)
end
-- ②效果的目标处理函数：先处理连锁中的对象合法性校验；在发动时检查对方场上是否有可加入手卡的卡；提示玩家选择并登记1张对方场上的卡为对象，同时设置操作信息为回手牌。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 在效果发动合法性检查阶段（chk==0），确认对方场上有至少1张可以被加入手卡的卡，否则②效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示选择提示，提示文字为“请选择要返回手牌的卡”（HINTMSG_RTOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 在对方场上选择1张可以被加入手卡的卡作为效果的对象，并通过SelectTarget将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息，声明之后处理会把这1张对象卡加入手卡（CATEGORY_TOHAND），用于后续时点/连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理函数：取得对象卡，若它仍然与当前效果关联（没有因连锁处理离场等），则将其返回持有者手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡（唯一对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）将对象卡送去持有者手卡，即“那张卡回到手卡”。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
