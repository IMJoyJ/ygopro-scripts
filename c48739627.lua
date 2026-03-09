--無垢なる予幻視
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「无垢者 米底乌斯」送去墓地才能发动。把对方卡组最上面的卡确认，回到卡组最上面或最下面。
-- ②：把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象，宣言种族和属性各1个才能发动。那只怪兽直到对方回合结束时变成宣言的种族·属性。
local s,id,o=GetID()
-- 注册卡牌效果，包括①②两个效果的初始化
function s.initial_effect(c)
	-- 记录该卡与「无垢者 米底乌斯」的关联
	aux.AddCodeList(c,97556336)
	-- ①：从卡组把1只「无垢者 米底乌斯」送去墓地才能发动。把对方卡组最上面的卡确认，回到卡组最上面或最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象，宣言种族和属性各1个才能发动。那只怪兽直到对方回合结束时变成宣言的种族·属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"变更属性"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.ratg)
	e2:SetOperation(s.raop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查场上是否有「无垢者 米底乌斯」且可作为墓地费用
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsCode(97556336) and c:IsAbleToGraveAsCost()
end
-- 效果处理函数：选择并送入墓地1只「无垢者 米底乌斯」
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足条件：场上存在至少1张「无垢者 米底乌斯」
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「无垢者 米底乌斯」
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡送入墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果处理函数：确认对方卡组最上方的卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足条件：对方卡组存在至少1张卡
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0 end
	-- 设置连锁对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
end
-- 效果处理函数：确认并移动对方卡组最上方的卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取对方卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(1-p,1)
	if g:GetCount()>0 then
		-- 向玩家展示对方卡组最上方的卡
		Duel.ConfirmCards(p,g)
		local tc=g:GetFirst()
		-- 提示玩家选择将卡放回卡组最上面或最下面
		local opt=Duel.SelectOption(p,aux.Stringid(id,2),aux.Stringid(id,3))  --"返回卡组最上面/返回卡组最下面"
		if opt==1 then
			-- 根据选择移动卡到卡组最下方
			Duel.MoveSequence(tc,opt)
		end
	end
end
-- 过滤函数：检查场上是否有可变更种族或属性的怪兽
function s.rafilter(c)
	return c:IsFaceup() and ((RACE_ALL&~c:GetRace())~=0 or (ATTRIBUTE_ALL&~c:GetAttribute())~=0)
end
-- 效果处理函数：选择目标怪兽并宣言种族与属性
function s.ratg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 判断是否满足条件：场上存在至少1只可变更种族或属性的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rafilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要变更种族和属性的目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	local tc=Duel.SelectTarget(tp,s.rafilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	local race,att
	-- 提示玩家宣言种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	if ATTRIBUTE_ALL&~tc:GetAttribute()==0 then
		-- 根据规则宣言种族
		race=Duel.AnnounceRace(tp,1,RACE_ALL&~tc:GetRace())
	else
		-- 根据规则宣言种族
		race=Duel.AnnounceRace(tp,1,RACE_ALL)
	end
	-- 提示玩家宣言属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	if RACE_ALL&~tc:GetRace()==0 or race==tc:GetRace() then
		-- 根据规则宣言属性
		att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~tc:GetAttribute())
	else
		-- 根据规则宣言属性
		att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	end
	e:SetLabel(race,att)
end
-- 效果处理函数：将目标怪兽变更种族与属性
function s.raop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local race,att=e:GetLabel()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 使目标怪兽的种族变为宣言的种族
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(race)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的属性变为宣言的属性
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(att)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e2)
	end
end
