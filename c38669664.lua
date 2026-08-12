--原質の炉心溶融
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从自己卡组上面把6张卡翻开，可以从那之中选1张「原质炉」卡加入手卡。剩余用喜欢的顺序回到卡组上面。那之后，可以把自己场上的3阶超量怪兽作为超量素材中的1张卡加入手卡。
-- ②：自己的超量怪兽把效果发动的场合才能发动。把自己卡组最上面的卡作为自己场上1只「原质炉」超量怪兽的超量素材。
local s,id,o=GetID()
-- 注册场地魔法卡的发动效果和两个效果，分别对应①②效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。从自己卡组上面把6张卡翻开，可以从那之中选1张「原质炉」卡加入手卡。剩余用喜欢的顺序回到卡组上面。那之后，可以把自己场上的3阶超量怪兽作为超量素材中的1张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"翻开卡组"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：自己的超量怪兽把效果发动的场合才能发动。把自己卡组最上面的卡作为自己场上1只「原质炉」超量怪兽的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"变成超量素材"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(s.ovcon)
	e3:SetTarget(s.ovtg)
	e3:SetOperation(s.ovop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件判断，检查玩家卡组是否至少有6张牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家卡组是否至少有6张牌
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>5 end
	-- 提示对方玩家发动了“翻开卡组”效果
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))  --"翻开卡组"
end
-- 筛选「原质炉」卡的过滤函数
function s.thfilter(c)
	return c:IsSetCard(0x160) and c:IsAbleToHand()
end
-- 筛选3阶超量怪兽的过滤函数
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsRank(3)
end
-- ①效果的处理函数，翻开卡组并处理加入手牌和超量素材的逻辑
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家卡组中卡的数量
	local dc=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if dc==0 then return end
	if dc>6 then dc=6 end
	-- 翻开玩家卡组最上方的指定数量的卡
	Duel.ConfirmDecktop(tp,dc)
	-- 获取翻开的卡组顶部卡的集合
	local g=Duel.GetDecktopGroup(tp,dc)
	local sd=true
	-- 判断翻开的卡中是否存在「原质炉」卡，并询问玩家是否要加入手牌
	if g:IsExists(s.thfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:FilterSelect(tp,s.thfilter,1,1,nil)
		-- 禁用后续操作的洗牌检测
		Duel.DisableShuffleCheck()
		-- 将选中的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切玩家手牌
		Duel.ShuffleHand(tp)
		if dc>1 then
			-- 将剩余的卡按玩家选择的顺序放回卡组顶部
			Duel.SortDecktop(tp,tp,dc-1)
		else
			sd=false
		end
	-- 将所有翻开的卡按玩家选择的顺序放回卡组顶部
	else Duel.SortDecktop(tp,tp,dc) end
	if sd then
		local rg=Group.CreateGroup()
		-- 获取玩家场上的所有超量怪兽
		local xg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
		if xg:GetCount()<1 then return end
		-- 遍历所有超量怪兽，收集其叠放的卡
		for tc in aux.Next(xg) do
			local hg=tc:GetOverlayGroup()
			if hg:GetCount()>0 then
				rg:Merge(hg)
			end
		end
		-- 判断是否有可加入手牌的叠放卡，并询问玩家是否要加入手牌
		if rg:FilterCount(Card.IsAbleToHand,nil)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把超量素材加入手卡？"
			-- 中断当前效果处理，使之后的效果视为不同时处理
			Duel.BreakEffect()
			local thg=rg:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
			-- 将选中的叠放卡加入手牌
			Duel.SendtoHand(thg,nil,REASON_EFFECT)
			local sg=thg:Filter(Card.IsControler,nil,tp)
			if sg:GetCount()>0 then
				-- 向对方玩家展示加入手牌的卡
				Duel.ConfirmCards(1-tp,sg)
				-- 洗切玩家手牌
				Duel.ShuffleHand(tp)
			end
			local og=thg:Filter(Card.IsControler,nil,1-tp)
			if og:GetCount()>0 then
				-- 向玩家展示加入手牌的卡
				Duel.ConfirmCards(tp,og)
				-- 洗切对方玩家手牌
				Duel.ShuffleHand(1-tp)
			end
		end
	end
end
-- ②效果的发动条件判断，检查是否为己方超量怪兽发动效果
function s.ovcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==tp and re:IsActiveType(TYPE_MONSTER) and rc:IsType(TYPE_XYZ)
end
-- 筛选「原质炉」超量怪兽的过滤函数
function s.matfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x160)
end
-- ②效果的发动条件判断，检查是否有「原质炉」超量怪兽和卡组顶部有卡
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有「原质炉」超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查玩家卡组是否至少有1张牌
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 提示对方玩家发动了“变成超量素材”效果
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))  --"变成超量素材"
end
-- ②效果的处理函数，将卡组顶部的卡作为超量素材
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	if g:GetCount()==1 then
		local tc=g:GetFirst()
		-- 禁用后续操作的洗牌检测
		Duel.DisableShuffleCheck()
		-- 检查是否有「原质炉」超量怪兽且该卡可作为超量素材
		if Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE,0,1,nil) and tc:IsCanOverlay() then
			-- 提示玩家选择表侧表示的超量怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			-- 选择一张表侧表示的「原质炉」超量怪兽
			local sg=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
			-- 将卡作为选中怪兽的超量素材
			Duel.Overlay(sg:GetFirst(),Group.FromCards(tc))
		else
			-- 将卡组顶部的卡送去墓地
			Duel.SendtoGrave(g,REASON_RULE)
		end
	end
end
