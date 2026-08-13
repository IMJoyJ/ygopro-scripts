--新風の空牙団
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不用「空牙团」怪兽不能攻击宣言。
-- ①：把自己场上1只怪兽解放才能发动。比那只怪兽等级高1星或低1星的1只「空牙团」怪兽从手卡·卡组特殊召唤。
function c48214588.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不用「空牙团」怪兽不能攻击宣言。①：把自己场上1只怪兽解放才能发动。比那只怪兽等级高1星或低1星的1只「空牙团」怪兽从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetCountLimit(1,48214588+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c48214588.cost)
	e1:SetTarget(c48214588.target)
	e1:SetOperation(c48214588.activate)
	c:RegisterEffect(e1)
	-- 注册自定义活动计数器，统计本回合玩家攻击宣言时使用的怪兽是否为「空牙团」，用于检测是否违反发动回合只能用「空牙团」攻击的自肃。
	Duel.AddCustomActivityCounter(48214588,ACTIVITY_ATTACK,c48214588.counterfilter)
end
-- 定义计数器过滤函数：仅当攻击宣言的怪兽属于「空牙团」字段时返回true，否则返回false，从而使非「空牙团」怪兽的攻击宣言会被计数器记录。
function c48214588.counterfilter(c)
	return c:IsSetCard(0x114)
end
-- 发动代价处理：先用e:SetLabel(100)标记代价已通过检查；若为合法性检测则确认本回合尚无非「空牙团」攻击宣言；随后给己方场上施加一个誓约效果，直到结束阶段非「空牙团」怪兽不能攻击宣言。
function c48214588.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 代价检测：若为发动合法性检测（chk==0），检查攻击计数器是否为0，即本回合没有用非「空牙团」怪兽攻击宣言过，只有为0才能发动。
	if chk==0 then return Duel.GetCustomActivityCount(48214588,tp,ACTIVITY_ATTACK)==0 end
	-- 这张卡发动的回合，自己不用「空牙团」怪兽不能攻击宣言。①：把自己场上1只怪兽解放才能发动。比那只怪兽等级高1星或低1星的1只「空牙团」怪兽从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c48214588.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将创建的自肃效果注册到场上，使其对己方怪兽区域生效，并会在结束阶段自动重置。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃效果的对象过滤条件：返回true表示该怪兽不是「空牙团」，即不能进行攻击宣言。
function c48214588.atktg(e,c)
	return not c:IsSetCard(0x114)
end
-- 定义可解放怪兽的过滤条件：需要满足等级大于0，且是我方控制或表侧表示的怪兽，解放后我方仍有怪兽区空位，并且手卡·卡组中存在可特殊召唤的符合条件的「空牙团」怪兽。
function c48214588.cfilter(c,e,tp)
	local lv=c:GetLevel()
	-- 检查解放对象的基本条件：怪兽等级大于0，且是（我方控制的或表侧表示的）怪兽，并且解放后我方场上仍有可用的怪兽区。
	return lv>0 and (c:IsControler(tp) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0
		-- 进一步检查：手卡·卡组中是否存在至少1只等级为该怪兽等级±1的「空牙团」怪兽可以特殊召唤，以确保解放后有可特殊召唤的目标。
		and Duel.IsExistingMatchingCard(c48214588.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,lv,e,tp)
end
-- 定义特殊召唤对象的过滤条件：等级等于目标等级+1或-1，属于「空牙团」字段，且能被当前效果特殊召唤（不检查召唤条件与苏生限制）。
function c48214588.spfilter(c,lv,e,tp)
	return c:IsLevel(lv+1,lv-1) and c:IsSetCard(0x114) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标处理：在chk==0时确认已通过代价检查且存在可解放怪兽与可特召目标；正式发动时选择我方场上1只满足条件的怪兽解放，记录其等级，并设置从手卡·卡组特殊召唤1只怪兽的操作信息。
function c48214588.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检测是否存在至少1只满足cfilter条件的可解放怪兽（即解放后能继续特殊召唤的怪兽）。
		return Duel.CheckReleaseGroup(tp,c48214588.cfilter,1,nil,e,tp)
	end
	-- 让玩家从我方场上选择1只满足条件的怪兽作为发动代价。
	local g=Duel.SelectReleaseGroup(tp,c48214588.cfilter,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetLevel())
	-- 将选择的怪兽解放，作为效果发动的代价（REASON_COST，不因免疫而无法支付）。
	Duel.Release(g,REASON_COST)
	-- 设置本次效果处理的操作信息：将进行1只怪兽的特殊召唤，来源为我方手卡·卡组，供连锁或相关效果的发动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：确认怪兽区有空位后，根据之前记录的等级从手卡·卡组选择1只符合条件的「空牙团」怪兽，以正面表示特殊召唤到我方场上。
function c48214588.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若我方场上没有空的怪兽区域，则无法特殊召唤，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	-- 弹出选择提示，引导玩家从手卡·卡组中选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中选出1只满足等级为记录等级±1、属于「空牙团」且可特殊召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,c48214588.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,lv,e,tp)
	if g:GetCount()>0 then
		-- 将选出的怪兽以正面表示特殊召唤到我方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
