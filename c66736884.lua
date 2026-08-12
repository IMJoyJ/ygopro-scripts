--空牙団の船匠 キール
-- 效果：
-- 种族不同的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「空牙团」魔法·陷阱卡或「飞龙艇-幻舵拉」在自己场上盖放。这个回合，自己不是「空牙团」怪兽不能特殊召唤。
-- ②：对方回合才能发动。墓地的这张卡除外，从手卡把1只「空牙团」怪兽特殊召唤。那之后，场上的原本攻击力最高的怪兽在对方场上存在的场合，可以让另1只特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 注册卡片关联密码，表明本卡效果中记载了「飞龙艇-幻舵拉」（卡号64400161）。
	aux.AddCodeList(c,64400161)
	c:EnableReviveLimit()
	-- 注册连接召唤手续：需要2只怪兽作为素材，且素材需满足s.lcheck过滤条件。
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「空牙团」魔法·陷阱卡或「飞龙艇-幻舵拉」在自己场上盖放。这个回合，自己不是「空牙团」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：对方回合才能发动。墓地的这张卡除外，从手卡把1只「空牙团」怪兽特殊召唤。那之后，场上的原本攻击力最高的怪兽在对方场上存在的场合，可以让另1只特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 连接素材的过滤条件：检查素材怪兽的种族是否各不相同。
function s.lcheck(g,lc)
	-- 检查素材怪兽组中是否存在相同的种族，若没有相同种族（即种族各不相同）则返回true。
	return not aux.SameValueCheck(g,Card.GetLinkRace)
end
-- 效果①的发动条件：此卡必须是通过连接召唤的方式特殊召唤成功。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的检索过滤条件：卡组中的「空牙团」魔法·陷阱卡，或者卡名为「飞龙艇-幻舵拉」且可以在场上盖放的卡。
function s.setfilter(c)
	return (c:IsSetCard(0x114) and c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsCode(64400161))
		and c:IsSSetable()
end
-- 效果①的发动准备（Target）：检查卡组中是否存在满足盖放条件的卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足s.setfilter过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果①的效果处理（Operation）：从卡组选择1张卡盖放，并适用本回合只能特殊召唤「空牙团」怪兽的限制。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要盖放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片在自己场上盖放。
		Duel.SSet(tp,g:GetFirst())
	end
	-- 这个回合，自己不是「空牙团」怪兽不能特殊召唤。②：对方回合才能发动。墓地的这张卡除外，从手卡把1只「空牙团」怪兽特殊召唤。那之后，场上的原本攻击力最高的怪兽在对方场上存在的场合，可以让另1只特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该特殊召唤限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的过滤函数：限制不能特殊召唤非「空牙团」怪兽。
function s.splimit(e,c)
	return not c:IsSetCard(0x114)
end
-- 效果②的发动条件：必须在对方回合才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是自己（即对方回合）。
	return Duel.GetTurnPlayer()~=tp
end
-- 效果②的特殊召唤过滤条件：手卡中的「空牙团」怪兽，且可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x114) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（Target）：检查此卡是否能除外、自己场上是否有空位，以及手卡中是否有可特殊召唤的「空牙团」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove()
		-- 检查自己场上的怪兽区域是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1张满足特殊召唤条件的「空牙团」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁的操作信息：预计将墓地的这张卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
	-- 设置连锁的操作信息：预计从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的效果处理（Operation）：将墓地的此卡除外，从手卡特殊召唤1只「空牙团」怪兽。若满足条件，可再特殊召唤1只。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 将墓地的这张卡除外，若除外失败则效果处理终止。
	if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)==0 then return end
	-- 检查自己场上是否有可用的怪兽区域，若没有则效果处理终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡中选择1张满足特殊召唤条件的「空牙团」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若成功选择怪兽，则将其以表侧表示特殊召唤到自己场上。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 刷新场地信息，以便准确获取场上怪兽的最新状态（如攻击力等）。
		Duel.AdjustAll()
		-- 获取双方场上所有表侧表示的怪兽。
		local ag=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		local tg=ag:GetMaxGroup(Card.GetBaseAttack)
		if tg:IsExists(Card.IsControler,1,nil,1-tp)
			-- 检查自己场上是否还有可用的怪兽区域。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查手卡中是否还存在可以特殊召唤的「空牙团」怪兽。
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
			-- 询问玩家是否选择发动追加特殊召唤的效果。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再特殊召唤？"
			-- 中断当前效果，使后续的特殊召唤处理与前一次特殊召唤不视为同时处理。
			Duel.BreakEffect()
			-- 给玩家发送提示信息，提示选择要追加特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从手卡中选择另1只满足特殊召唤条件的「空牙团」怪兽。
			local g2=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			-- 将选中的第2只怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
