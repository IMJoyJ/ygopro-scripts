--真炎竜アルビオン
-- 效果：
-- 「阿不思的落胤」＋魔法师族·光属性怪兽
-- 这张卡不能作为融合素材。这个卡名的②③的效果1回合各能使用1次。
-- ①：对方不能把场上的这张卡作为效果的对象。
-- ②：对方回合，以自己·对方的墓地的怪兽合计2只为对象才能发动。那些怪兽在双方场上各1只特殊召唤。
-- ③：这张卡在墓地存在的场合才能发动。额外怪兽区域以及双方的中央的主要怪兽区域存在的4只怪兽解放，这张卡特殊召唤。
function c38811586.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为68468459的1只怪兽和1个满足matfilter条件的怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,68468459,c38811586.matfilter,1,true,true)
	-- 这张卡不能作为融合素材。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- 对方不能把场上的这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果值为tgoval函数，用于过滤对方效果不能选择自己为对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 对方回合，以自己·对方的墓地的怪兽合计2只为对象才能发动。那些怪兽在双方场上各1只特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38811586,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,38811586)
	e3:SetCondition(c38811586.spcon)
	e3:SetTarget(c38811586.sptg)
	e3:SetOperation(c38811586.spop)
	c:RegisterEffect(e3)
	-- 这张卡在墓地存在的场合才能发动。额外怪兽区域以及双方的中央的主要怪兽区域存在的4只怪兽解放，这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,38811587)
	e4:SetTarget(c38811586.spittg)
	e4:SetOperation(c38811586.spitop)
	c:RegisterEffect(e4)
end
-- 融合召唤时检查是否满足融合条件：一张名为阿不思的落胤的卡和一张满足matfilter条件的卡
function c38811586.branded_fusion_check(tp,sg,fc)
	-- 调用gffcheck函数检查融合素材是否满足条件
	return aux.gffcheck(sg,Card.IsFusionCode,68468459,c38811586.matfilter)
end
-- 定义融合素材的过滤条件：光属性且魔法师族
function c38811586.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER)
end
-- 设置效果发动条件：当前回合不是自己回合
function c38811586.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家不是自己
	return Duel.GetTurnPlayer()~=tp
end
-- 定义墓地怪兽过滤条件：可以成为效果对象且为怪兽类型
function c38811586.spfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsType(TYPE_MONSTER)
end
-- 定义特殊召唤条件1：该怪兽可以特殊召唤且在目标组中存在满足条件2的怪兽
function c38811586.spsumfilter1(c,e,tp,g)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
		and g:IsExists(c38811586.spsumfilter2,1,c,e,tp)
end
-- 定义特殊召唤条件2：该怪兽可以特殊召唤到对方场上
function c38811586.spsumfilter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 定义组内是否存在满足条件1的怪兽
function c38811586.gcheck(g,e,tp)
	return g:IsExists(c38811586.spsumfilter1,1,nil,e,tp,g)
end
-- 设置特殊召唤效果的目标选择和处理逻辑
function c38811586.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取满足条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(c38811586.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp)
	if chk==0 then
		-- 获取自己场上可用的怪兽区数量
		local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 获取对方场上可用的怪兽区数量
		local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133) and ft1>0 and ft2>0
			and g:IsExists(c38811586.spsumfilter1,1,nil,e,tp,g)
	end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c38811586.gcheck,false,2,2,e,tp)
	-- 设置当前连锁的目标卡为sg
	Duel.SetTargetCard(sg)
	-- 设置操作信息：将要特殊召唤2只怪兽到双方墓地
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,LOCATION_GRAVE)
end
-- 设置特殊召唤效果的处理逻辑
function c38811586.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区数量
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取对方场上可用的怪兽区数量
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or ft1<=0 or ft2<=0 then return end
	-- 获取当前连锁相关的卡组
	local g=Duel.GetTargetsRelateToChain()
	if #g~=2 then return end
	-- 提示玩家选择要在自己场上特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(38811586,1))  --"请选择要在自己场上特殊召唤的怪兽"
	local sg=g:FilterSelect(tp,c38811586.spsumfilter1,1,1,nil,e,tp,g)
	if #sg==0 then return end
	-- 特殊召唤sg中的第一张卡到自己场上
	Duel.SpecialSummonStep(sg:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
	-- 特殊召唤g-sg中的第一张卡到对方场上
	Duel.SpecialSummonStep((g-sg):GetFirst(),0,tp,1-tp,false,false,POS_FACEUP)
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 定义解放过滤条件：可以被效果解放且在额外怪兽区或中央怪兽区
function c38811586.rfilter(c)
	return c:IsReleasableByEffect() and (c:GetSequence()>4 or c:GetSequence()==2)
end
-- 设置墓地发动效果的目标选择和处理逻辑
function c38811586.spittg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取满足条件的场上怪兽组
	local rg=Duel.GetMatchingGroup(c38811586.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	-- 检查是否满足发动条件：卡可以特殊召唤且有4只以上满足条件的怪兽可解放
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and #rg>=4 and Duel.GetMZoneCount(tp,rg)>0 end
	-- 设置操作信息：将要特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置操作信息：将要解放4只怪兽
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,rg,4,0,0)
end
-- 设置墓地发动效果的处理逻辑
function c38811586.spitop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取满足条件的场上怪兽组
	local rg=Duel.GetMatchingGroup(c38811586.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 检查是否满足发动条件：有4只满足条件的怪兽可解放且卡在连锁中
	if #rg==4 and Duel.Release(rg,REASON_EFFECT)==4 and c:IsRelateToEffect(e) then
		-- 将卡特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
