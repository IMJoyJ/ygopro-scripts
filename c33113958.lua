--リヴァーチュ・ドラゴン
-- 效果：
-- 3星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「善德激流弹」加入手卡。
-- ②：可以从以下效果选择1个发动。
-- ●自己场上1个超量素材取除。那之后，从自己墓地把「海善龙」以外的1只鱼族·海龙族·水族怪兽加入手卡。
-- ●以场上2只超量怪兽为对象才能发动。那之内的1只的1个超量素材作为另1只的超量素材。
local s,id,o=GetID()
-- 初始化效果：登记记载卡名「善德激流弹」、设置超量召唤手续并启用苏生限制，然后注册①特殊召唤时检索效果、②取除超量素材回收墓地效果、③转移超量素材效果
function s.initial_effect(c)
	-- 登记这张卡上记载着卡名「善德激流弹」（卡号80534031）
	aux.AddCodeList(c,80534031)
	-- 设置超量召唤手续：用2只3星怪兽叠放进行超量召唤
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「善德激流弹」加入手卡。这个卡名的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：可以从以下效果选择1个发动。●自己场上1个超量素材取除。那之后，从自己墓地把「海善龙」以外的1只鱼族·海龙族·水族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收墓地"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
	-- ②：可以从以下效果选择1个发动。●以场上2只超量怪兽为对象才能发动。那之内的1只的1个超量素材作为另1只的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"转移超量素材"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选卡名为「善德激流弹」且可以加入手卡的卡
function s.thfilter(c)
	return c:IsCode(80534031) and c:IsAbleToHand()
end
-- ①效果的对象函数：确认卡组存在可检索的卡并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中需存在至少1张可加入手卡的「善德激流弹」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：宣告将从卡组把1张卡加入手卡（CATEGORY_TOHAND）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：让玩家从卡组选择1张「善德激流弹」加入手卡并展示给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1张满足条件的「善德激流弹」
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡以效果原因加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡展示给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：筛选「海善龙」以外的鱼族·海龙族·水族且可以加入手卡的怪兽
function s.thfilter2(c)
	return not c:IsCode(id) and c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT)
		and c:IsAbleToHand()
end
-- ②回收效果的对象函数：确认能取除超量素材且墓地存在可加入手卡的怪兽，并设置操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：能以效果原因取除自己场上1个超量素材，且自己墓地存在至少1只「海善龙」以外的鱼族·海龙族·水族怪兽
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：宣告将从墓地把1张卡加入手卡（CATEGORY_TOHAND）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ②回收效果的处理：先取除自己场上1个超量素材，那之后从自己墓地选择1只符合条件的怪兽加入手卡并展示给对方确认
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认能取除超量素材，并取除自己场上1个超量素材，若取除失败则中断处理
	if not Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) or Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT)==0 then return end
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只「海善龙」以外的鱼族·海龙族·水族怪兽（经王家长眠之谷过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 中断当前效果处理，使取除素材与加入手卡视为不同时处理（错时点）
		Duel.BreakEffect()
		-- 把选择的怪兽以效果原因加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡展示给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：筛选表侧表示的超量怪兽且可以作为这个效果的对象的卡
function s.xyzfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e)
end
-- 子组检查函数：检查组内是否至少存在1只持有超量素材的表侧表示超量怪兽
function s.gcheck(g)
	return g:IsExists(s.xyzfilter2,1,nil)
end
-- 过滤函数：筛选表侧表示且持有1个以上超量素材的超量怪兽
function s.xyzfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayGroup():GetCount()>0
end
-- ②转移素材效果的对象函数：取得场上可作为对象的超量怪兽，确认并选择满足条件的2只作为效果对象
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 取得双方场上所有表侧表示且可作为这个效果对象的超量怪兽
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2)
	-- 把选择的2只超量怪兽设置为当前连锁的对象卡
	Duel.SetTargetCard(sg)
end
-- ②转移素材效果的处理：取得对象的2只超量怪兽，让玩家选择其中1只失去超量素材，把它的1个超量素材作为另1只的超量素材，并触发取除素材时点
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()~=2 or not tg:IsExists(s.xyzfilter2,1,nil) then return end
	-- 提示玩家选择失去超量素材的那只怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))  --"请选择失去超量素材的那只怪兽"
	local tg2=tg:FilterSelect(tp,s.xyzfilter2,1,1,nil)
	tg:Sub(tg2)
	local tc=tg2:GetFirst()
	local tc2=tg:GetFirst()
	if tc2 and not tc2:IsImmuneToEffect(e) then
		local og=tc:GetOverlayGroup()
		local sg=og:Select(tp,1,1,nil)
		-- 把选择的1个超量素材叠放到另一只对象怪兽下面
		Duel.Overlay(tc2,sg,false)
		local oc=sg:GetFirst():GetOverlayTarget()
		-- 为被取除超量素材的怪兽触发单体「超量素材被取除」时点
		Duel.RaiseSingleEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
		-- 触发群体「超量素材被取除」时点
		Duel.RaiseEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	end
end
