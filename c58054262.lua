--マシンナーズ・フォース
-- 效果：
-- 这张卡不能通常召唤。「督战官 科文顿」的效果才能特殊召唤。
-- ①：这张卡若不支付1000基本分则不能攻击宣言。
-- ②：把场上的这张卡送去墓地，以自己墓地的「机甲士兵」「机甲狙击兵」「机甲卫兵」各1只为对象才能发动。那些怪兽特殊召唤。
function c58054262.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。「督战官 科文顿」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c58054262.splimit)
	c:RegisterEffect(e1)
	-- ①：这张卡若不支付1000基本分则不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_COST)
	e2:SetCost(c58054262.atcost)
	e2:SetOperation(c58054262.atop)
	c:RegisterEffect(e2)
	-- ②：把场上的这张卡送去墓地，以自己墓地的「机甲士兵」「机甲狙击兵」「机甲卫兵」各1只为对象才能发动。那些怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58054262,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c58054262.spcost)
	e3:SetTarget(c58054262.sptg)
	e3:SetOperation(c58054262.spop)
	c:RegisterEffect(e3)
end
-- 创建用于检查「机甲士兵」、「机甲狙击兵」、「机甲卫兵」卡号的条件检查函数数组
c58054262.spchecks=aux.CreateChecks(Card.IsCode,{60999392,23782705,96384007})
-- 限制特殊召唤条件，仅能由「督战官 科文顿」的效果特殊召唤
function c58054262.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(22666164)
end
-- 攻击宣言代价的检测函数，检查玩家是否能支付1000基本分
function c58054262.atcost(e,c,tp)
	-- 检查玩家是否能支付1000基本分
	return Duel.CheckLPCost(tp,1000)
end
-- 攻击宣言代价的执行函数，让玩家支付1000基本分
function c58054262.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 效果②的发动代价，检查并把场上的这张卡送去墓地
function c58054262.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 作为发动代价，将自身送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数，检查卡片是否为指定卡号且可以特殊召唤
function c58054262.filter(c,code,e,tp)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数，检查墓地中的卡是否为「机甲士兵」、「机甲狙击兵」或「机甲卫兵」，且可以作为效果对象并特殊召唤
function c58054262.sptargetfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCode(60999392,23782705,96384007) and c:IsCanBeEffectTarget(e)
end
-- 效果②的发动准备（target），进行发动条件检查并选择对象
function c58054262.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地中满足特殊召唤条件的「机甲士兵」、「机甲狙击兵」、「机甲卫兵」卡片组
	local g=Duel.GetMatchingGroup(c58054262.sptargetfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查在自身离开场上后，自己场上可用的怪兽区域数量是否大于等于3
		and Duel.GetMZoneCount(tp,e:GetHandler())>=3
		and g:CheckSubGroupEach(c58054262.spchecks)
	end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroupEach(tp,c58054262.spchecks)
	-- 将选择的卡片组设为当前效果的对象
	Duel.SetTargetCard(sg)
	-- 设置连锁的操作信息，表示此效果包含特殊召唤3张选定卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,3,0,0)
end
-- 效果②的效果处理（operation），将选定的3只怪兽特殊召唤
function c58054262.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己场上的怪兽区域空格是否小于3，若小于3则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
	-- 获取当前连锁中设为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	-- 将对象怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
