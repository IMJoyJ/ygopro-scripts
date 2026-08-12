--レッド・デーモンズ・チェーン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡也能把额外卡组1只「红莲魔龙」给对方观看，在盖放的回合发动。
-- ①：把手卡的怪兽任意数量给对方观看，以那之内的调整数量＋1只的对方场上的效果怪兽为对象才能把这张卡发动。只要这张卡在魔法与陷阱区域存在，作为对象的怪兽的攻击力下降从手卡给人观看的数量×100，效果无效化。作为对象的怪兽不在场上存在的场合这张卡破坏。
local s,id,o=GetID()
-- 注册这张卡的发动效果以及盖放回合可以发动的特殊发动规则效果。
function s.initial_effect(c)
	-- 将「红莲魔龙」的卡片密码（70902743）注册到这张卡记载的卡号列表中。
	aux.AddCodeList(c,70902743)
	-- ①：把手卡的怪兽任意数量给对方观看，以那之内的调整数量＋1只的对方场上的效果怪兽为对象才能把这张卡发动。只要这张卡在魔法与陷阱区域存在，作为对象的怪兽的攻击力下降从手卡给人观看的数量×100，效果无效化。作为对象的怪兽不在场上存在的场合这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这张卡也能把额外卡组1只「红莲魔龙」给对方观看，在盖放的回合发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"适用「红莲魔族之链」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCost(s.accost)
	c:RegisterEffect(e2)
end
-- 过滤手牌中可展示的怪兽的过滤函数。
function s.cfilter(c,ct)
	return c:IsType(TYPE_MONSTER) and not c:IsPublic()
		and (ct>1 or not c:IsType(TYPE_TUNER))
end
-- 用于限制展示手牌怪兽数量不超过对方场上效果怪兽总数，且展示的调整数量少于该限制的辅助检查函数。
function s.gcheck(g,ct)
	return g:FilterCount(Card.IsType,nil,TYPE_TUNER)<ct
end
-- 效果发动的代价处理：将手牌中任意数量的怪兽给对方确认，并记录其中调整的数量和总数量。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上满足过滤条件的效果怪兽数量。
	local ct=Duel.GetTargetCount(s.filter,tp,0,LOCATION_MZONE,nil)
	-- 代价检测：确认手牌中是否存在至少1只可展示的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,ct) end
	-- 获取手牌中所有可供展示的怪兽卡片组。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil,ct)
	-- 提示玩家选择给对方确认的手牌卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,1,g:GetCount(),ct)
	-- 将选中的手牌怪兽给对方确认（展示）。
	Duel.ConfirmCards(1-tp,sg)
	-- 洗切玩家的手牌。
	Duel.ShuffleHand(tp)
	e:SetLabel(sg:FilterCount(Card.IsType,nil,TYPE_TUNER),sg:GetCount())
end
-- 过滤场上表侧表示的效果怪兽的过滤函数。
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 效果发动的靶向处理：选择展示手牌中调整数量＋1只的对方场上的效果怪兽作为对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) and chkc:IsControler(1-tp) end
	-- 靶向检测：确认对方场上是否存在至少1只可以作为对象的效果怪兽。
	if chk==0 then return e:IsCostChecked() and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	local ct,_=e:GetLabel()
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择展示手牌怪兽中调整数量＋1数量的对方场上的效果怪兽作为对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,ct+1,ct+1,nil)
	-- 设置当前连锁的操作信息：使作为对象的怪兽效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 效果处理：使所有有效的对象怪兽效果无效，攻击力下降展示数量×100，并在这张卡或对象怪兽离场时作相应处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local _,atk=e:GetLabel()
	-- 从连锁信息中获取作为效果对象的怪兽卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsType,nil,TYPE_MONSTER)
	local tg=g:Filter(Card.IsRelateToChain,nil)
	local fid=c:GetFieldID()
	if tg:GetCount()>0 then
		-- 效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_TARGET)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetRange(LOCATION_SZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 作为对象的怪兽的攻击力下降从手卡给人观看的数量×100
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_TARGET)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetRange(LOCATION_SZONE)
		e2:SetValue(atk*-100)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 作为对象的怪兽不在场上存在的场合这张卡破坏。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e3:SetRange(LOCATION_SZONE)
		e3:SetCode(EFFECT_SELF_DESTROY)
		e3:SetCondition(s.descon)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	else
		-- 场上不存在任何有效对象时，将这张卡破坏。
		Duel.Destroy(c,REASON_EFFECT)
		return
	end
	-- 循环处理每个与该连锁相关的对象怪兽。
	for tc in aux.Next(tg) do
		c:SetCardTarget(tc)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	end
end
-- 确认作为对象的怪兽是否都不在场上存在的条件判断函数。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCardTarget():GetCount()==0
end
-- 过滤额外卡组中未公开的「红莲魔龙」的过滤函数。
function s.costfilter(c)
	return c:IsCode(70902743) and not c:IsPublic()
end
-- 盖放回合发动的代价处理：从额外卡组将1只「红莲魔龙」给对方观看并确认。
function s.accost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认额外卡组中是否存在可以展示的「红莲魔龙」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择给对方确认的额外卡组卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从额外卡组中选择1只「红莲魔龙」。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选中的「红莲魔龙」给对方确认。
	Duel.ConfirmCards(1-tp,g)
end
