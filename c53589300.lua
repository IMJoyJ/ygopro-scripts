--創獄神ネルヴァ
-- 效果：
-- 「神艺」怪兽×3
-- 自己对「创狱神 涅瓦」1回合只能有1次特殊召唤。这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把种族不同的自己场上3只怪兽解放的场合可以守备表示特殊召唤。
-- ①：只要场地区域有卡存在，这张卡不会被效果破坏。
-- ②：1回合1次，自己把「神艺」怪兽的效果发动时才能发动。那个效果变成「对方场上的卡全部破坏」。
local s,id,o=GetID()
-- 注册怪兽卡的全部效果：限定1回合1次特殊召唤，添加「神艺」×3融合召唤手续，设定仅能用融合召唤或解放3只不同种族怪兽的方式从额外卡组特殊召唤，注册①的场地区有卡时不因效果破坏，注册②的1回合1次把「神艺」效果变为破坏对方全场。
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	-- 为这张卡添加融合召唤手续：以3只满足s.ffilter条件的「神艺」怪兽作为融合素材。
	aux.AddFusionProcFunRep(c,s.ffilter,3,true)
	c:EnableReviveLimit()
	-- 对应效果原文：这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetRange(LOCATION_EXTRA)
	-- 设置特殊召唤条件判定值：仅当特殊召唤类型为融合召唤（SUMMON_TYPE_FUSION）时才允许从额外卡组特殊召唤，即不能用融合召唤以外的方式特殊召唤。
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- 对应效果原文：把种族不同的自己场上3只怪兽解放的场合可以守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	-- 对应效果原文：①：只要场地区域有卡存在，这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 对应效果原文：②：1回合1次，自己把「神艺」怪兽的效果发动时才能发动。那个效果变成「对方场上的卡全部破坏」。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"效果变更"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.chcon)
	e3:SetTarget(s.chtg)
	e3:SetOperation(s.chop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断一张怪兽卡是否为「神艺」系列怪兽，作为融合素材的筛选条件。
function s.ffilter(c)
	return c:IsFusionSetCard(0x1cd)
end
-- 过滤函数：判断怪兽能否作为本卡规则特殊召唤的解放素材——必须是自己场上的、可因特殊召唤而解放、且能作为这张卡的融合素材的怪兽。
function s.hspfilter(c,tp,sc)
	return c:IsControler(tp) and c:IsReleasable(REASON_SPSUMMON)
		and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 检查一组素材是否满足特殊召唤条件：解放这些素材后额外卡组仍有空位可特殊召唤本卡，并且组内3只怪兽的种族各不相同。
function s.hspchk(g,tp,sc)
	-- 返回解放这些素材后从额外卡组特殊召唤本卡是否有可用怪兽区域（空位）大于0。
	return Duel.GetLocationCountFromEx(tp,tp,g,sc)>0
		and g:GetClassCount(Card.GetRace)==#g
end
-- 规则特殊召唤手续的发动条件：若c为nil则视为规则询问返回true；否则从自己场上筛选所有可作素材的怪兽，检查是否存在3只种族不同且解放后有空位的子组。
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 取得己方场上所有可作为解放素材的怪兽，作为规则特殊召唤的候选素材组。
	local rg=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,0,nil,tp,e:GetHandler())
	return rg:CheckSubGroup(s.hspchk,3,3,tp,e:GetHandler())
end
-- 规则特殊召唤手续的选素材处理：在候选素材中选择3只满足条件（种族不同且解放后有空位）的怪兽，选中后保存该素材组并返回true，否则返回false。
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得己方场上所有可解放的候选怪兽，供玩家在发动规则特殊召唤时选择。
	local rg=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE,0,nil,tp,e:GetHandler())
	-- 向玩家显示选择解放卡片的提示信息，提示文字为“请选择要解放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,s.hspchk,true,3,3,tp,e:GetHandler())
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 规则特殊召唤手续的处理：取出之前选好的素材组，将其解放，然后清理临时组，完成这次特殊召唤的代价。
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为由，将选中的3只素材怪兽解放。
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- ①效果的适用条件：只要双方场地区存在至少1张卡，本卡不会被效果破坏。
function s.indcon(e)
	-- 检查双方场地区（自己的场地魔法区和对方的场地魔法区）合计是否有至少1张卡，存在则条件成立。
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- ②效果的发动条件：自己发动「神艺」怪兽的效果时才能发动（1回合1次限制由SetCountLimit实现）。判定要求是当前连锁的效果为自己控制的怪兽效果，且对应怪兽是「神艺」系列；同时处理了效果发动后怪兽离场的情况（用PreviousSetCard判定）。
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	local b1=re:GetHandler():IsRelateToEffect(re) and ec:IsSetCard(0x1cd)
	local b2=re:GetActivateLocation()==LOCATION_MZONE and not ec:IsLocation(LOCATION_MZONE) and ec:IsPreviousSetCard(0x1cd)
	return rp==tp and re:IsActiveType(TYPE_MONSTER) and (b1 or b2)
end
-- ②效果发动时的合法性检查：对方场上至少存在1张卡，才能发动（确保效果变更后有可破坏的卡）。
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0（发动时）确认对方场上有至少1张卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,rp,0,LOCATION_ONFIELD,1,nil) end
end
-- ②效果处理：将当前连锁中的「神艺」效果的对象改为空组，并将其处理函数替换为s.repop，从而实现“那个效果变成『对方场上的卡全部破坏』”。
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 清空原「神艺」效果的对象（改为空组），使其不再对原对象进行处理。
	Duel.ChangeTargetCard(ev,g)
	-- 将当前连锁上的原效果处理函数替换为s.repop，使原效果处理时改为执行破坏对方全场卡的效果。
	Duel.ChangeChainOperation(ev,s.repop)
end
-- 变更后实际执行的效果处理：获取对方场上所有卡并将它们全部破坏。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方场上的所有卡（怪兽区和魔法陷阱区，包括里侧表示），作为要被破坏的卡集合。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果破坏为由，将对方场上的全部卡破坏。
	Duel.Destroy(sg,REASON_EFFECT)
end
