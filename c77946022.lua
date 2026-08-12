--天威無窮の境地
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「虚空之龙轮」或「天幻之龙轮」加入手卡。
-- ②：把自己场上1只幻龙族怪兽解放，以场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ③：自己结束阶段才能发动。这张卡送去墓地，从自己的卡组·墓地把1张「天威无崩之地」在自己的场地区域表侧表示放置。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动、破坏效果和结束阶段放置场地效果
function s.initial_effect(c)
	-- 注册卡片关联的卡名列表（虚空之龙轮、天幻之龙轮、天威无崩之地）
	aux.AddCodeList(c,51684157,65124425,39730727)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1张「虚空之龙轮」或「天幻之龙轮」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把自己场上1只幻龙族怪兽解放，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段才能发动。这张卡送去墓地，从自己的卡组·墓地把1张「天威无崩之地」在自己的场地区域表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"表侧表示放置"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 检索卡片过滤条件：卡名为「虚空之龙轮」或「天幻之龙轮」且能加入手卡
function s.thfilter(c)
	return c:IsCode(51684157,65124425) and c:IsAbleToHand()
end
-- 卡片发动时的效果处理函数：可以从卡组选择1张「虚空之龙轮」或「天幻之龙轮」加入手卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中满足检索条件的卡片组
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 检查是否存在可检索的卡，并询问玩家是否发动该效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡因效果加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 解放怪兽的过滤条件：自己场上的幻龙族怪兽，且场上存在除其以外的怪兽作为破坏对象
function s.cfilter(c,tp)
	return c:IsRace(RACE_WYRM) and (c:IsControler(tp) or c:IsFaceup())
		-- 检查场上是否存在至少1只除被解放怪兽以外的怪兽作为效果对象
		and Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 破坏效果的发动代价处理函数：解放自己场上1只幻龙族怪兽
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查自己场上是否存在可作为代价解放的幻龙族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择1只满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(g,REASON_COST)
end
-- 破坏效果的目标选择函数：选择场上1只怪兽为对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 步骤0：检查场上是否存在可作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：破坏选中的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行函数：将作为对象的怪兽破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 将该怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 放置效果的发动条件函数：必须在自己的结束阶段
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 放置卡片的过滤条件：卡名为「天威无崩之地」且未被限制放置
function s.setfilter(c)
	return c:IsCode(39730727) and not c:IsForbidden()
end
-- 步骤0：检查此卡是否能送去墓地，且自己的卡组或墓地是否存在「天威无崩之地」
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc,exc)
	if chk==0 then return e:GetHandler():IsAbleToGrave()
		-- 检查自己的卡组或墓地是否存在至少1张「天威无崩之地」
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理信息：将此卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 放置效果的执行函数：将此卡送去墓地，并从卡组或墓地将「天威无崩之地」表侧表示放置
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍存在于场上，并将其送去墓地，确认成功送去墓地
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 从卡组或墓地选择1张「天威无崩之地」（受王家之谷影响）
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
		if sc then
			-- 获取自己场地区域的卡片
			local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if fc then
				-- 将原本存在的场地魔法卡因规则送去墓地
				Duel.SendtoGrave(fc,REASON_RULE)
				-- 中断当前效果处理，使后续的放置处理不与送去墓地同时进行
				Duel.BreakEffect()
			end
			-- 将选中的「天威无崩之地」在自己的场地区域表侧表示放置
			Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		end
	end
end
