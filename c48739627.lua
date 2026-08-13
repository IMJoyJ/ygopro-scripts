--無垢なる予幻視
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「无垢者 米底乌斯」送去墓地才能发动。把对方卡组最上面的卡确认，回到卡组最上面或最下面。
-- ②：把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象，宣言种族和属性各1个才能发动。那只怪兽直到对方回合结束时变成宣言的种族·属性。
local s,id,o=GetID()
-- 注册这张卡的两个效果：①作为魔法卡发动，以从卡组送墓1只「无垢者 米底乌斯」为代价，确认对方卡组顶1张卡并选择放回最上面或最下面；②墓地中除外自身，以自己场上1只表侧表示怪兽为对象，宣言种族和属性各1个，使其直到对方回合结束时变成宣言的种族·属性。两个效果通过id和id+o分别计数，实现同名卡1回合各1次。
function s.initial_effect(c)
	-- 登记本卡文本中提到的「无垢者 米底乌斯」的卡名，用于规则上判定这张卡记载着该卡名。
	aux.AddCodeList(c,97556336)
	-- 对应①效果：“从卡组把1只「无垢者 米底乌斯」送去墓地才能发动。把对方卡组最上面的卡确认，回到卡组最上面或最下面。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 对应②效果：“把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象，宣言种族和属性各1个才能发动。那只怪兽直到对方回合结束时变成宣言的种族·属性。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"变更属性"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价为把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.ratg)
	e2:SetOperation(s.raop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡是「无垢者 米底乌斯」且可以作为代价送去墓地。
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsCode(97556336) and c:IsAbleToGraveAsCost()
end
-- ①效果的代价处理：先检查卡组是否存在符合条件的卡，存在则让玩家从卡组选择1只「无垢者 米底乌斯」送去墓地作为发动代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己卡组中存在至少1只符合过滤条件的「无垢者 米底乌斯」，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 弹出“请选择要送去墓地的卡”的选择提示，引导玩家选择代价卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己卡组中选择1张符合条件的「无垢者 米底乌斯」。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的卡以代价方式送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果的发动条件与对象记录：要求对方卡组有卡才能发动，并把发动者记录为当前连锁的目标玩家，以便处理阶段读取对方卡组。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：对方卡组至少存在1张卡（否则无法确认卡组最上面的卡）。
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0 end
	-- 将发动者设为当前连锁的目标玩家，后续处理时通过该信息确定要确认的是对方的卡组。
	Duel.SetTargetPlayer(tp)
end
-- ①效果处理：确认对方卡组最上面1张卡，并让其选择放回卡组最上面或最下面。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时记录的目标玩家（即发动者）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 取得该目标玩家的对方卡组最上方的1张卡。
	local g=Duel.GetDecktopGroup(1-p,1)
	if g:GetCount()>0 then
		-- 向发动者展示/确认对方卡组最上面的那张卡。
		Duel.ConfirmCards(p,g)
		local tc=g:GetFirst()
		-- 让发动者选择该卡放回卡组最上面还是最下面（选项顺序对应最上面/最下面）。
		local opt=Duel.SelectOption(p,aux.Stringid(id,2),aux.Stringid(id,3))  --"返回卡组最上面/返回卡组最下面"
		if opt==1 then
			-- 当选择“放回卡组最下面”时，将该卡移动到卡组最下方。
			Duel.MoveSequence(tc,opt)
		end
	end
end
-- 过滤条件：选择自己场上表侧表示的怪兽，且该怪兽的种族或属性至少有一项可以通过宣言改变（即存在不同于当前的种族或属性可选）。
function s.rafilter(c)
	return c:IsFaceup() and ((RACE_ALL&~c:GetRace())~=0 or (ATTRIBUTE_ALL&~c:GetAttribute())~=0)
end
-- ②效果的取对象与宣言处理：选择自己场上1只表侧表示怪兽为对象，再让玩家宣言1个种族和1个属性；若对象属性已无可变空间，则种族只能从非当前种族中选，否则种族任意宣言；若对象种族已无可变空间或宣言种族等于当前种族，则属性只能从非当前属性中选，否则属性任意宣言，最后将宣言值存入效果标签。
function s.ratg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 取对象条件检查：自己场上存在至少1只符合条件的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.rafilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出“请选择表侧表示的卡”的选择提示，引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只符合条件的表侧表示怪兽作为对象，并取得该对象。
	local tc=Duel.SelectTarget(tp,s.rafilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	local race,att
	-- 弹出“请选择要宣言的种族”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	if ATTRIBUTE_ALL&~tc:GetAttribute()==0 then
		-- 当对象的属性已没有可变更的剩余属性时，宣言的种族只能从非当前种族中选择。
		race=Duel.AnnounceRace(tp,1,RACE_ALL&~tc:GetRace())
	else
		-- 否则，宣言的种族可以从全种族中任意选择。
		race=Duel.AnnounceRace(tp,1,RACE_ALL)
	end
	-- 弹出“请选择要宣言的属性”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	if RACE_ALL&~tc:GetRace()==0 or race==tc:GetRace() then
		-- 当对象的种族已没有可变更的剩余种族，或已宣言的种族与对象当前种族相同时，宣言的属性只能从非当前属性中选择。
		att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~tc:GetAttribute())
	else
		-- 否则，宣言的属性可以从全属性中任意选择。
		att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	end
	e:SetLabel(race,att)
end
-- ②效果处理：取得对象怪兽和宣言的种族·属性，给对象怪兽附加改变种族和改变属性的效果，直到对方回合结束时重置。
function s.raop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local race,att=e:GetLabel()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 对应效果原文“那只怪兽直到对方回合结束时变成宣言的种族”（种族变更部分）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(race)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
		-- 对应效果原文“变成宣言的种族·属性”中的“变成宣言的属性”（属性变更部分）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(att)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e2)
	end
end
