--リンクスレイヤー＠イグニスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上的电子界族怪兽作为「@火灵天星」连接怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
-- ②：这张卡作为连接素材送去墓地的场合，丢弃1张手卡，以场上1张魔法·陷阱卡为对象才能发动（场上的这张卡为素材的场合，这个效果的对象可以变成2张）。那张卡破坏。
local s,id,o=GetID()
-- 注册卡片效果：①手卡作为连接素材，②作为连接素材送去墓地时丢弃手卡破坏场上魔陷
function s.initial_effect(c)
	-- ①：把自己场上的电子界族怪兽作为「@火灵天星」连接怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetValue(s.matval)
	c:RegisterEffect(e1)
	-- ②：这张卡作为连接素材送去墓地的场合，丢弃1张手卡，以场上1张魔法·陷阱卡为对象才能发动（场上的这张卡为素材的场合，这个效果的对象可以变成2张）。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上的电子界族怪兽
function s.mfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsRace(RACE_CYBERSE)
end
-- 过滤条件：手卡中的同名卡
function s.exmfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsCode(id)
end
-- 判定手卡中的此卡是否能作为「@火灵天星」连接怪兽的连接素材
function s.matval(e,lc,mg,c,tp)
	if not lc:IsSetCard(0x135) then return false,nil end
	return true,not mg or mg:IsExists(s.mfilter,1,nil,tp) and not mg:IsExists(s.exmfilter,1,nil)
end
-- 效果②的发动条件：此卡作为连接素材送去墓地（若从场上送墓则记录Label为1）
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	e:SetLabel(0)
	if c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND) and r==REASON_LINK then
		if c:IsPreviousLocation(LOCATION_ONFIELD) then
			e:SetLabel(1)
			c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))  --"从场上送去墓地"
		end
		return true
	else
		return false
	end
end
-- 效果②的代价：丢弃1张手卡
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：检查手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：魔法·陷阱卡
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果②的靶向：选择场上的魔法·陷阱卡作为对象（若从场上送墓则可选择最多2张）
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.desfilter(chkc) end
	-- 靶向检测：检查场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上的魔法·陷阱卡作为对象（数量上限取决于是否从场上送墓）
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1+e:GetLabel(),nil)
	-- 设置操作信息：破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果②的效果处理：破坏作为对象的卡片
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取仍与该连锁相关的对象卡片
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()>0 then
		-- 破坏这些卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
