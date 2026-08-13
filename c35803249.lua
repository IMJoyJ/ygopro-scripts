--人造人間－サイコ・ロード
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只表侧表示的「人造人-念力震慑者」送去墓地的场合才能特殊召唤。
-- ①：只要这张卡在怪兽区域存在，双方不能把场上的陷阱卡的效果发动，场上的陷阱卡的效果无效化。
-- ②：1回合1次，自己主要阶段才能发动。场上的表侧表示的陷阱卡全部破坏，给与对方破坏数量×300伤害。
function c35803249.initial_effect(c)
	-- 将「人造人-念力震慑者」（77585513）登记为此卡记载的卡名，以便识别和关联效果描述中提到的该卡。
	aux.AddCodeList(c,77585513)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己场上1只表侧表示的「人造人-念力震慑者」送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的判定值设为false，使此卡不能通过其他效果特殊召唤，只能通过自身注册的特殊召唤手续上场。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 把自己场上1只表侧表示的「人造人-念力震慑者」送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c35803249.spcon)
	e2:SetTarget(c35803249.sptg)
	e2:SetOperation(c35803249.spop)
	c:RegisterEffect(e2)
	-- ①：双方不能把场上的陷阱卡的效果发动
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_SZONE,LOCATION_HAND+LOCATION_SZONE)
	e3:SetTarget(c35803249.distg)
	c:RegisterEffect(e3)
	-- 场上的陷阱卡的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e4:SetTarget(c35803249.distg)
	c:RegisterEffect(e4)
	-- 场上的陷阱卡的效果无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(c35803249.disop)
	c:RegisterEffect(e5)
	-- 场上的陷阱卡的效果无效化。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetTarget(c35803249.distg)
	c:RegisterEffect(e6)
	-- ②：1回合1次，自己主要阶段才能发动。场上的表侧表示的陷阱卡全部破坏，给与对方破坏数量×300伤害。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(35803249,0))  --"表侧的陷阱卡全部破坏"
	e7:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetTarget(c35803249.destg)
	e7:SetOperation(c35803249.desop)
	c:RegisterEffect(e7)
end
-- 筛选目标卡是否为陷阱卡，作为「场上的陷阱卡」的判定条件，用于①效果的发动禁止和无效化。
function c35803249.distg(e,c)
	return c:IsType(TYPE_TRAP)
end
-- 在连锁处理时，若确认连锁来自魔陷区且发动者类型为陷阱卡，则将该连锁的发动无效化，从而场上的陷阱卡无法发动效果。
function c35803249.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的发生位置，用于判断该连锁是否来自魔陷区（即是否属于场上的陷阱卡效果）。
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl==LOCATION_SZONE and re:IsActiveType(TYPE_TRAP) then
		-- 使该次陷阱卡效果发动无效化，对应①效果中‘不能把场上的陷阱卡的效果发动’的发动无效处理。
		Duel.NegateEffect(ev)
	end
end
-- 定义特殊召唤素材条件：该卡必须是表侧表示的「人造人-念力震慑者」，可以作为代价送去墓地，且送墓后自己场上仍存在可用的怪兽区。
function c35803249.spfilter(c,tp)
	-- 逐一检查：c是表侧表示、卡名为「人造人-念力震慑者」、可作为代价送去墓地、且送墓后能腾出怪兽区，全部满足才可作为素材。
	return c:IsFaceup() and c:IsCode(77585513) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤手续的条件判定：若c为nil（规则询问）直接通过；否则检查自己场上是否存在1只可送去墓地表侧「人造人-念力震慑者」。
function c35803249.spcon(e,c)
	if c==nil then return true end
	-- 检索自己怪兽区是否存在至少1张满足spfilter条件的「人造人-念力震慑者」，有则满足特殊召唤的发动条件。
	return Duel.IsExistingMatchingCard(c35803249.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetControler())
end
-- 特殊召唤手续的选素材阶段：从自己场上的符合条件的「人造人-念力震慑者」中选择1张，暂存至效果Label中；未选择则返回false。
function c35803249.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足素材条件的「人造人-念力震慑者」组成候选组，供玩家选择。
	local g=Duel.GetMatchingGroup(c35803249.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 弹出“选择要送去墓地的卡”的提示信息，并进入选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤手续：取出之前选中的「人造人-念力震慑者」，将其作为代价送去墓地，从而完成特殊召唤。
function c35803249.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的「人造人-念力震慑者」送入墓地，作为特殊召唤的代价。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
-- 定义②效果要破坏的对象条件：表侧表示的陷阱卡。
function c35803249.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP)
end
-- ②效果发动时：检查场上是否有表侧陷阱卡；若有，则将场上所有表侧陷阱卡登记为破坏对象，并登记给对方造成破坏数量×300的伤害。
function c35803249.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段，确认场上至少存在1张表侧表示陷阱卡，否则不能发动②效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c35803249.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取当前场上所有表侧表示的陷阱卡，作为要被全部破坏的对象集合。
	local sg=Duel.GetMatchingGroup(c35803249.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 向系统登记本次连锁的破坏操作信息：破坏目标为sg，数量为sg:GetCount()，用于连锁计算与后续处理。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 向系统登记本次连锁的伤害操作信息：给对方玩家造成sg:GetCount()*300的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,sg:GetCount()*300)
end
-- ②效果实际处理：重新获取场上表侧表示的陷阱卡并全部破坏，然后按实际破坏数量给对方造成300点/张的伤害。
function c35803249.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行时获取场上现存的所有表侧表示陷阱卡，确保破坏的是处理时仍在场上的卡。
	local sg=Duel.GetMatchingGroup(c35803249.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 用效果将检索到的表侧表示陷阱卡全部破坏，并记录实际被破坏的数量ct。
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	-- 给予对方玩家(1-tp)以实际破坏数量ct*300的伤害。
	Duel.Damage(1-tp,ct*300,REASON_EFFECT)
end
