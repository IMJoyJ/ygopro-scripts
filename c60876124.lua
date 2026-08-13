--レア・ヴァリュー
-- 效果：
-- ①：自己的魔法与陷阱区域有「宝玉兽」卡2张以上存在的场合才能发动。自己的魔法与陷阱区域1张「宝玉兽」卡由对方选出。对方选的卡送去墓地，自己从卡组抽2张。
function c60876124.initial_effect(c)
	-- ①：自己的魔法与陷阱区域有「宝玉兽」卡2张以上存在的场合才能发动。自己的魔法与陷阱区域1张「宝玉兽」卡由对方选出。对方选的卡送去墓地，自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c60876124.condition)
	e1:SetTarget(c60876124.target)
	e1:SetOperation(c60876124.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡是否为表侧表示且属于「宝玉兽」系列（SetCard 0x1034）。
function c60876124.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1034)
end
-- 发动条件函数：检查我方魔法与陷阱区域是否存在至少2张满足filter条件的「宝玉兽」卡。
function c60876124.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定我方魔法与陷阱区域是否存在至少2张表侧表示的「宝玉兽」卡。
	return Duel.IsExistingMatchingCard(c60876124.filter,tp,LOCATION_SZONE,0,2,nil)
end
-- 发动时目标/合法性处理：确认我方可以抽2张卡，并设置操作信息为抽卡2张。
function c60876124.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：在chk==0的确认阶段，判定我方是否满足抽2张卡的条件。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置本连锁的处理信息：效果分类为抽卡（CATEGORY_DRAW），由我方（tp）抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：获取我方魔法与陷阱区域的「宝玉兽」卡，若存在则让对手选择1张送去墓地；若该卡确实进入墓地，则我方抽2张卡。
function c60876124.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方魔法与陷阱区域所有表侧表示的「宝玉兽」卡集合。
	local g=Duel.GetMatchingGroup(c60876124.filter,tp,LOCATION_SZONE,0,nil)
	if g:GetCount()>0 then
		-- 向对方玩家提示“请选择要送去墓地的卡”（HINTMSG_TOGRAVE），并准备让对手选择1张卡。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 将对方选择的「宝玉兽」卡以效果原因（REASON_EFFECT）送入墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
		if sg:GetFirst():IsLocation(LOCATION_GRAVE) then
			-- 我方以效果原因（REASON_EFFECT）从卡组抽2张卡。
			Duel.Draw(tp,2,REASON_EFFECT)
		end
	end
end
