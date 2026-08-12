--ガガガガガール
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡有「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」卡的其中任意种在作为超量素材的场合，把这张卡1个超量素材取除才能发动。「我我我」、「拟声」、「超量」卡的其中1张从卡组加入手卡。
-- ②：有这张卡在作为超量素材中的「未来皇 霍普」超量怪兽得到以下效果。
-- ●这张卡超量召唤的场合发动。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
local s,id,o=GetID()
-- 初始化效果，注册超量召唤手续、①的起动效果以及②的作为超量素材时赋予其他怪兽效果的契约效果
function s.initial_effect(c)
	-- 添加超量召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡有「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」卡的其中任意种在作为超量素材的场合，把这张卡1个超量素材取除才能发动。「我我我」、「拟声」、「超量」卡的其中1张从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"2次攻击（我我我我少女）"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：有这张卡在作为超量素材中的「未来皇 霍普」超量怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"2次攻击（我我我我少女）"
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetLabelObject(c)
	e2:SetCondition(s.eacon)
	e2:SetOperation(s.addop)
	c:RegisterEffect(e2)
end
-- ①的效果发动条件：这张卡有「刷拉拉」、「我我我」、「隆隆隆」、「怒怒怒」卡在作为超量素材
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x8f,0x54,0x59,0x82)
end
-- ①的效果发动代价：把这张卡1个超量素材取除
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤卡组中「我我我」、「拟声」、「超量」卡片且能加入手牌的过滤条件
function s.thfilter(c)
	return c:IsSetCard(0x54,0x13a,0x73) and c:IsAbleToHand()
end
-- ①的效果发动目标：检查卡组中是否存在可检索的卡，并设置将卡加入手牌的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「我我我」、「拟声」或「超量」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①的效果处理：从卡组选择1张满足条件的卡加入手牌并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「我我我」、「拟声」或「超量」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 赋予效果的处理：在超量怪兽特殊召唤成功时，为其注册获得的效果，并触发自定义事件
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetLabelObject()
	-- ●这张卡超量召唤的场合发动。
	local e2=Effect.CreateEffect(c)
	local eid=EVENT_CUSTOM+id+ec:GetFieldID()
	e2:SetDescription(aux.Stringid(id,1))  --"2次攻击（我我我我少女）"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(eid)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetLabelObject(ec)
	e2:SetTarget(s.eatg)
	e2:SetOperation(s.eaop)
	c:RegisterEffect(e2)
	-- 触发单体自定义事件，使获得效果的超量怪兽发动其诱发效果
	Duel.RaiseSingleEvent(c,eid,re,r,rp,ep,ev)
end
-- 检查获得效果的怪兽是否是「未来皇 霍普」且进行的是超量召唤
function s.eacon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSetCard(0x207f) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 赋予效果的发动目标：检查作为超量素材的这张卡是否仍在该怪兽下叠放，并向对方提示发动了该效果
function s.eatg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetOverlayGroup():IsContains(e:GetLabelObject()) end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 赋予效果的效果处理：给该怪兽添加在同一次战斗阶段中可以作2次攻击的效果
function s.eaop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
