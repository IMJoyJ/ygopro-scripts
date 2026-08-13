--メガリス・ノートラ・プルーラ
-- 效果：
-- 「巨石遗物」卡降临
-- 这张卡若非以只使用仪式怪兽来作的仪式召唤则不能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。这个回合，对方不能对应自己的「巨石遗物」仪式怪兽的效果的发动把效果发动。
-- ②：对方把卡的效果发动时才能发动。那个发动无效并破坏。这个效果把以场上的卡为对象的效果的发动无效的场合，可以再把对方场上1只怪兽解放。
local s,id,o=GetID()
-- 初始化卡的效果注册：登记仪式召唤限制（仅允许仪式召唤方式特殊召唤），并注册①手牌展示效果（限制对方连锁）和②对方效果发动无效并破坏、可追加解放的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 「巨石遗物」卡降临 这张卡若非以只使用仪式怪兽来作的仪式召唤则不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件值：只有以仪式召唤方式进行的特殊召唤才被允许，其他召唤方式无法特殊召唤。
	e0:SetValue(aux.ritlimit)
	c:RegisterEffect(e0)
	-- ①：把手卡的这张卡给对方观看才能发动。这个回合，对方不能对应自己的「巨石遗物」仪式怪兽的效果的发动把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"反制连锁"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.prcost)
	e1:SetOperation(s.prop)
	c:RegisterEffect(e1)
	-- ②：对方把卡的效果发动时才能发动。那个发动无效并破坏。这个效果把以场上的卡为对象的效果的发动无效的场合，可以再把对方场上1只怪兽解放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
-- 定义仪式召唤的素材过滤函数：素材卡必须同时拥有怪兽和仪式类型，确保仪式召唤时只使用仪式怪兽作为祭品。
function s.mat_filter(c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER)
end
-- ①效果的发动代价：检查手卡中的这张卡尚未公开，需要将其给对方观看（展示）作为发动COST。
function s.prcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- ①效果发动后的处理：创建一个持续效果并注册，在该回合内每当有连锁发生时检查是否为自己的「巨石遗物」仪式怪兽效果，为设置连锁限制做准备；该效果在结束阶段重置。
function s.prop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方不能对应自己的「巨石遗物」仪式怪兽的效果的发动把效果发动。②：对方把卡的效果发动时才能发动。那个发动无效并破坏。这个效果把以场上的卡为对象的效果的发动无效的场合，可以再把对方场上1只怪兽解放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(s.actop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将创建好的持续效果注册到当前玩家tp，使其在该回合内持续监听连锁事件。
	Duel.RegisterEffect(e1,tp)
end
-- 当连锁发生时，如果该连锁是己方发动的「巨石遗物」仪式怪兽的怪兽效果，则立即设置连锁限制，使对方不能对应这个效果发动。
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsAllTypes(TYPE_MONSTER+TYPE_RITUAL) and rc:IsSetCard(0x138) and re:IsActiveType(TYPE_MONSTER) and ep==tp then
		-- 设置连锁限制条件为s.chainlm，只允许原效果发动者（自己）连锁，禁止对方连锁自己的「巨石遗物」仪式怪兽效果。
		Duel.SetChainLimit(s.chainlm)
	end
end
-- 连锁限制函数：只有尝试连锁的玩家与原效果发动者相同（tp==rp）时返回true，否则返回false，从而禁止对方对应发动。
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- ②效果发动条件：不能在自己发动的效果连锁时使用；自己未被战斗破坏；若对方发动的是以场上的卡为对象的效果，则检查其对象中是否有场上的卡并记录到标签；最后要求该发动可以被无效。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		-- 取得当前连锁效果的对象卡组，用于判断该效果是否为以场上的卡为对象。
		local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		if g and g:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD) then
			e:SetLabel(1)
		else
			e:SetLabel(0)
		end
	else
		e:SetLabel(0)
	end
	-- 判断对方发动的效果是否可以被无效化，只有可被无效的效果才满足本卡②效果的发动条件。
	return Duel.IsChainNegatable(ev)
end
-- ②效果的目标阶段：无需选择对象；登记无效该效果的操作信息，并在其来源卡可被破坏且仍关联于该连锁时，一并登记破坏操作。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本次处理会无效的对象为eg（对方发动的效果），数量为1，用于无效效果的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记操作信息：本次处理会破坏的对象为eg（对方发动效果的那张卡），数量为1，为破坏处理作记录。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果处理：无效对方效果的发动并破坏该效果卡；若被无效的效果是以场上的卡为对象且对方场上有可解放怪兽，则询问是否追加解放，选择是则选1只对方怪兽解放。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 先判断无效对方效果的发动是否成功，且该效果来源卡仍与当前连锁相关，确保后续能够破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev)
		-- 判断破坏该效果来源卡是否成功（破坏数不为0），只有成功破坏才继续进行追加解放的判断。
		and Duel.Destroy(eg,REASON_EFFECT)~=0
		and e:GetLabel()==1
		-- 检查对方场上是否存在至少1只可被效果解放的怪兽，以决定是否可以追加解放。
		and Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,nil)
		-- 通过YES/NO询问让发动者选择是否追加解放对方怪兽。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽解放？"
		-- 给出选择解放对象的UI提示信息，HINTMSG_RELEASE表示要选择解放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 由发动者从对方场上选择1只可被效果解放的怪兽，作为追加解放对象。
		local g=Duel.SelectMatchingCard(tp,Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 中断当前效果处理，使后续解放处理作为独立事件，避免错过时点。
			Duel.BreakEffect()
			-- 手动展示被选中的解放对象并登记其为对象，保证后续解放事件正常触发。
			Duel.HintSelection(g)
			-- 将选中的对方怪兽以效果原因解放，完成追加解放处理。
			Duel.Release(g,REASON_EFFECT)
		end
	end
end
