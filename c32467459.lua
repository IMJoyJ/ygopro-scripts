--エルシャドール・メシャフレール
-- 效果：
-- 「影依」怪兽＋暗属性怪兽＋地属性怪兽
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：场上的这张卡不受对方发动的魔法·陷阱卡的效果影响，也不受原本的等级·阶级的数值比这张卡的等级低的对方怪兽发动的效果影响。
-- ②：1回合1次，支付800基本分才能发动。从卡组把1张「影依」卡或「炼狱」魔法·陷阱卡加入手卡。
-- ③：这张卡被送去墓地的场合才能发动。从自己墓地把1只「影依」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，启用复活限制并注册多个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：场上的这张卡不受对方发动的魔法·陷阱卡的效果影响，也不受原本的等级·阶级的数值比这张卡的等级低的对方怪兽发动的效果影响。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_FUSION_MATERIAL)
	e0:SetCondition(s.FShaddollCondition)
	e0:SetOperation(s.FShaddollOperation)
	c:RegisterEffect(e0)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡的特殊召唤条件为必须通过融合召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：场上的这张卡不受对方发动的魔法·陷阱卡的效果影响，也不受原本的等级·阶级的数值比这张卡的等级低的对方怪兽发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	-- ②：1回合1次，支付800基本分才能发动。从卡组把1张「影依」卡或「炼狱」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的场合才能发动。从自己墓地把1只「影依」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 效果过滤函数，用于判断是否免疫某个效果
function s.efilter(e,te)
	if te:GetHandlerPlayer()==e:GetHandlerPlayer() or not te:IsActivated() then
		return false
	end
	if te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then
		return true
	else
		-- 判断是否免疫原本等级·阶级比这张卡等级低的对方怪兽发动的效果
		return aux.qlifilter(e,te)
	end
end
-- 支付800基本分的费用处理
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 扣除玩家800基本分
	Duel.PayLPCost(tp,800)
end
-- 检索卡牌的过滤函数，筛选「影依」或「炼狱」魔法·陷阱卡
function s.thfilter(c)
	return (c:IsSetCard(0x9d) or c:IsSetCard(0xc5) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToHand()
end
-- 设置检索效果的目标信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡牌加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 特殊召唤卡牌的过滤函数，筛选「影依」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x9d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的卡牌
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 特殊召唤效果的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡牌
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡牌特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 融合素材过滤函数，筛选满足融合条件的卡
function s.FShaddollFilter(c,fc)
	return (c:IsFusionSetCard(0x9d) or c:IsFusionAttribute(ATTRIBUTE_DARK+ATTRIBUTE_EARTH) or c:IsHasEffect(4904633))
		and c:IsCanBeFusionMaterial(fc) and not c:IsHasEffect(6205579)
end
-- 额外融合素材过滤函数，筛选场上正面表示且未被免疫的卡
function s.FShaddollExFilter(c,fc,fe)
	return c:IsFaceup() and not c:IsImmuneToEffect(fe) and s.FShaddollFilter(c,fc)
end
-- 融合条件检查函数，判断是否满足融合条件
function s.FShaddollFilter1(c,g)
	return c:IsFusionSetCard(0x9d) and g:IsExists(s.FShaddollFilter2,1,c,g,c)
end
-- 融合条件检查函数，判断是否满足融合条件
function s.FShaddollFilter2(c,g,gc)
	return (c:IsFusionAttribute(ATTRIBUTE_DARK) or c:IsHasEffect(4904633))
		and g:IsExists(s.FShaddollFilter3,1,Group.FromCards(c,gc))
end
-- 融合条件检查函数，判断是否满足融合条件
function s.FShaddollFilter3(c)
	return c:IsFusionAttribute(ATTRIBUTE_EARTH) or c:IsHasEffect(4904633)
end
-- 融合条件检查函数，判断是否满足融合条件
function s.FShaddollCheck(g,gc,fc,tp,c,chkf,exg)
	if gc and not g:IsContains(gc) then return false end
	-- 检查额外融合素材是否超过1个
	if exg and g:FilterCount(aux.IsInGroup,nil,exg)>1 then return false end
	-- 检查是否包含调弦之魔术师效果
	if g:IsExists(aux.TuneMagicianCheckX,1,nil,g,EFFECT_TUNE_MAGICIAN_F) then return false end
	-- 检查是否满足必须成为融合素材的条件
	if not aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_FMATERIAL) then return false end
	-- 检查是否满足额外融合条件
	if aux.FCheckAdditional and not aux.FCheckAdditional(tp,g,fc)
		-- 检查是否满足额外融合条件
		or aux.FGoalCheckAdditional and not aux.FGoalCheckAdditional(tp,g,fc) then return false end
	return g:IsExists(s.FShaddollFilter1,1,nil,g)
		-- 检查是否满足融合位置条件
		and (chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,g,fc)>0)
end
-- 融合条件判断函数
function s.FShaddollCondition(e,g,gc,chkf)
	-- 当g为nil时，检查是否满足必须成为融合素材的条件
	if g==nil then return aux.MustMaterialCheck(nil,e:GetHandlerPlayer(),EFFECT_MUST_BE_FMATERIAL) end
	local c=e:GetHandler()
	local mg=g:Filter(s.FShaddollFilter,nil,c)
	local tp=e:GetHandlerPlayer()
	-- 获取玩家场上的魔法区域的卡
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	local exg=nil
	if fc and fc:IsHasEffect(81788994) and fc:IsCanRemoveCounter(tp,0x16,3,REASON_EFFECT) then
		local fe=fc:IsHasEffect(81788994)
		-- 获取满足额外融合条件的卡组
		exg=Duel.GetMatchingGroup(s.FShaddollExFilter,tp,0,LOCATION_MZONE,mg,c,fe)
	end
	if exg then mg:Merge(exg) end
	if gc and not mg:IsContains(gc) then return false end
	return mg:CheckSubGroup(s.FShaddollCheck,3,3,gc,fc,tp,c,chkf,exg)
end
-- 融合操作处理函数
function s.FShaddollOperation(e,tp,eg,ep,ev,re,r,rp,gc,chkf)
	local c=e:GetHandler()
	local mg=eg:Filter(s.FShaddollFilter,nil,c)
	-- 获取玩家场上的魔法区域的卡
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	local exg=nil
	if fc and fc:IsHasEffect(81788994) and fc:IsCanRemoveCounter(tp,0x16,3,REASON_EFFECT) then
		local fe=fc:IsHasEffect(81788994)
		-- 获取满足额外融合条件的卡组
		exg=Duel.GetMatchingGroup(s.FShaddollExFilter,tp,0,LOCATION_MZONE,mg,c,fe)
	end
	if exg then mg:Merge(exg) end
	-- 提示玩家选择作为融合素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
	local g=mg:SelectSubGroup(tp,s.FShaddollCheck,false,3,3,gc,c,tp,c,chkf,exg)
	-- 判断是否使用了额外融合素材
	if exg and g:IsExists(aux.IsInGroup,1,nil,exg) then
		fc:RemoveCounter(tp,0x16,3,REASON_EFFECT)
	end
	-- 设置融合素材
	Duel.SetFusionMaterial(g)
end
