--真炎竜アルビオン
-- 效果：
-- 「阿不思的落胤」＋魔法师族·光属性怪兽
-- 这张卡不能作为融合素材。这个卡名的②③的效果1回合各能使用1次。
-- ①：对方不能把场上的这张卡作为效果的对象。
-- ②：对方回合，以自己·对方的墓地的怪兽合计2只为对象才能发动。那些怪兽在双方场上各1只特殊召唤。
-- ③：这张卡在墓地存在的场合才能发动。额外怪兽区域以及双方的中央的主要怪兽区域存在的4只怪兽解放，这张卡特殊召唤。
function c38811586.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以1只‘阿不思的落胤’（卡号68468459）和1只满足matfilter条件（魔法师族·光属性）的怪兽作为融合素材。
	aux.AddFusionProcCodeFun(c,68468459,c38811586.matfilter,1,true,true)
	-- “这张卡不能作为融合素材。”
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- “①：对方不能把场上的这张卡作为效果的对象。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置此效果的判定值为aux.tgoval：当尝试以这张卡为对象的玩家不是其控制者时判定为真，从而实现‘对方不能把场上的这张卡作为效果的对象’。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- “②：对方回合，以自己·对方的墓地的怪兽合计2只为对象才能发动。那些怪兽在双方场上各1只特殊召唤。”
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
	-- “③：这张卡在墓地存在的场合才能发动。额外怪兽区域以及双方的中央的主要怪兽区域存在的4只怪兽解放，这张卡特殊召唤。”
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,38811587)
	e4:SetTarget(c38811586.spittg)
	e4:SetOperation(c38811586.spitop)
	c:RegisterEffect(e4)
end
-- 定义融合素材组的合法性检查函数，用于验证选择的素材组是否满足‘阿不思的落胤’＋魔法师族·光属性怪兽的组合（顺序不限）。
function c38811586.branded_fusion_check(tp,sg,fc)
	-- 调用aux.gffcheck检查素材组sg：其中一张卡是阿不思的落胤（卡号68468459），另一张卡满足matfilter（魔法师族·光属性），顺序不限。
	return aux.gffcheck(sg,Card.IsFusionCode,68468459,c38811586.matfilter)
end
-- 定义素材过滤函数：此卡须为光属性且魔法师族，用于判定是否为合格的融合素材。
function c38811586.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER)
end
-- 定义效果②的发动条件函数：仅在对方的回合允许发动。
function c38811586.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是这张卡的控制者，即满足‘对方回合’的发动条件。
	return Duel.GetTurnPlayer()~=tp
end
-- 定义效果②选择墓地目标的过滤函数：目标必须是能成为效果对象的怪兽卡。
function c38811586.spfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsType(TYPE_MONSTER)
end
-- 定义用于特殊召唤到自己场上的怪兽过滤函数：该卡可被特殊召唤到自己场上，且剩余素材中存在一张可特殊召唤到对方场上的卡。
function c38811586.spsumfilter1(c,e,tp,g)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
		and g:IsExists(c38811586.spsumfilter2,1,c,e,tp)
end
-- 定义用于特殊召唤到对方场上的怪兽过滤函数：该卡可被特殊召唤到对方场上。
function c38811586.spsumfilter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 定义素材组的整体检查函数：组内至少存在一张能特殊召唤到自己场上的卡，并且能与另一张能特殊召唤到对方场上的卡配对。
function c38811586.gcheck(g,e,tp)
	return g:IsExists(c38811586.spsumfilter1,1,nil,e,tp,g)
end
-- 效果②的发动时目标选择与合法性判定：获取双方墓地中可作为对象的怪兽，检查双方怪兽区域空格且不受‘青眼精灵龙’影响，再从候选中选出2只作为对象，设置从墓地特殊召唤的操作信息。
function c38811586.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取双方墓地中可作为效果对象且为怪兽的卡集合。
	local g=Duel.GetMatchingGroup(c38811586.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp)
	if chk==0 then
		-- 获取自己主要怪兽区域的空格数。
		local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 获取对方主要怪兽区域的空格数（以自己视角计算对方区域的可用格子）。
		local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133) and ft1>0 and ft2>0
			and g:IsExists(c38811586.spsumfilter1,1,nil,e,tp,g)
	end
	-- 弹出‘请选择要特殊召唤的卡’的提示，让玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c38811586.gcheck,false,2,2,e,tp)
	-- 将选中的2只墓地怪兽设置为当前效果的对象。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：本效果涉及特殊召唤，从墓地特殊召唤2只怪兽，双方玩家都可能涉及。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,LOCATION_GRAVE)
end
-- 效果②的解决处理：再次确认双方仍有可用怪兽区且不受‘青眼精灵龙’限制，从对象中选1只特殊召唤到自己场上，另1只特殊召唤到对方场上。
function c38811586.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次计算自己主要怪兽区域的空格数。
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 处理时再次计算对方主要怪兽区域的空格数。
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or ft1<=0 or ft2<=0 then return end
	-- 取得与当前连锁相关的对象卡集合（即发动时选择的2只墓地怪兽）。
	local g=Duel.GetTargetsRelateToChain()
	if #g~=2 then return end
	-- 提示玩家选择要特殊召唤到自己场上的那只怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(38811586,1))  --"请选择要在自己场上特殊召唤的怪兽"
	local sg=g:FilterSelect(tp,c38811586.spsumfilter1,1,1,nil,e,tp,g)
	if #sg==0 then return end
	-- 将选择的第一只怪兽以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummonStep(sg:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
	-- 将剩下的另一只怪兽以表侧表示特殊召唤到对方场上。
	Duel.SpecialSummonStep((g-sg):GetFirst(),0,tp,1-tp,false,false,POS_FACEUP)
	-- 完成这次连续特殊召唤的处理。
	Duel.SpecialSummonComplete()
end
-- 定义解放候选过滤函数：怪兽可被效果解放，且处于额外怪兽区域（sequence>4）或中央主要怪兽区域（sequence==2），适用于双方场上对应区域。
function c38811586.rfilter(c)
	return c:IsReleasableByEffect() and (c:GetSequence()>4 or c:GetSequence()==2)
end
-- 效果③发动时的条件检查与操作信息设置：验证这张卡可从墓地特殊召唤、场上有至少4只解放候选且解放后仍有空格，然后设置特殊召唤自己和解放4只怪兽的操作信息。
function c38811586.spittg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取双方场上满足解放条件的怪兽集合。
	local rg=Duel.GetMatchingGroup(c38811586.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	-- 发动合法性检查：这张卡可被特殊召唤、解放候选至少4只、解放后自己场上仍有空格。
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and #rg>=4 and Duel.GetMZoneCount(tp,rg)>0 end
	-- 设置操作信息：此效果将特殊召唤这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置操作信息：此效果将解放集合rg中的4只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,rg,4,0,0)
end
-- 效果③的解决处理：重新获取解放候选，若正好为4只则解放它们，然后将这张卡从墓地特殊召唤到自己场上。
function c38811586.spitop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时重新获取场上满足解放条件的怪兽集合。
	local rg=Duel.GetMatchingGroup(c38811586.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 如果解放候选正好4张且实际解放成功4张，并且这张卡仍与效果关联，则继续执行特殊召唤。
	if #rg==4 and Duel.Release(rg,REASON_EFFECT)==4 and c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
