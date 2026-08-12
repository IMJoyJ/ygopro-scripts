--守護竜ピスティ
-- 效果：
-- 4星以下的龙族怪兽1只
-- 自己对「守护龙 毗斯缇」1回合只能有1次特殊召唤，那个②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己不是龙族怪兽不能特殊召唤。
-- ②：以自己的墓地·除外状态的1只龙族怪兽为对象才能发动。那只怪兽在作为受2只以上的连接怪兽所连接区的自己场上特殊召唤。
function c13143275.initial_effect(c)
	c:SetSPSummonOnce(13143275)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用1到1个满足条件的连接素材
	aux.AddLinkProcedure(c,c13143275.matfilter,1,1)
	-- 只要这张卡在怪兽区域存在，自己不是龙族怪兽不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c13143275.splimit)
	c:RegisterEffect(e1)
	-- 以自己的墓地·除外状态的1只龙族怪兽为对象才能发动。那只怪兽在作为受2只以上的连接怪兽所连接区的自己场上特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13143275,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,13143275)
	e2:SetTarget(c13143275.sptg)
	e2:SetOperation(c13143275.spop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤器，筛选4星以下的龙族怪兽
function c13143275.matfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkRace(RACE_DRAGON)
end
-- 特殊召唤限制函数，阻止非龙族怪兽的特殊召唤
function c13143275.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsRace(RACE_DRAGON)
end
-- 连接怪兽过滤器，筛选正面表示的连接怪兽
function c13143275.lkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 特殊召唤目标过滤器，筛选可特殊召唤的龙族怪兽
function c13143275.spfilter(c,e,tp,zone)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果发动时的处理函数，用于选择目标怪兽
function c13143275.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前玩家所有被多只连接怪兽指向的区域
	local zone=aux.GetMultiLinkedZone(tp)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c13143275.spfilter(chkc,e,tp,zone) end
	-- 判断是否满足发动条件，检查是否有可用区域且场上存在目标怪兽
	if chk==0 then return zone~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件，检查是否存在符合条件的目标怪兽
		and Duel.IsExistingTarget(c13143275.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,zone) end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择符合条件的目标怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c13143275.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,zone)
	-- 设置当前连锁的操作信息，确定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时的执行函数，用于执行特殊召唤操作
function c13143275.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家所有被多只连接怪兽指向的区域
	local zone=aux.GetMultiLinkedZone(tp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if zone~=0 and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示形式特殊召唤到指定区域
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
