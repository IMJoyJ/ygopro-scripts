--M・HERO アトミック
-- 效果：
-- 这张卡用「假面变化」的效果才能特殊召唤。这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以炎属性以外的自己的墓地·除外状态的1只「假面英雄」怪兽为对象才能发动。那只怪兽无视召唤条件守备表示特殊召唤。
-- ②：这张卡1回合只有1次不会被战斗·效果破坏。
-- ③：自己结束阶段，以自己墓地1张「变化」速攻魔法卡为对象才能发动。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化效果注册：设置特殊召唤限制、①效果（特殊召唤时特召墓地/除外的假面英雄）、②效果（一回合一次抗破坏）、③效果（结束阶段盖放墓地变化速攻魔法）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡用「假面变化」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为必须符合「假面变化」的召唤限制
	e1:SetValue(aux.MaskChangeLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤的场合，以炎属性以外的自己的墓地·除外状态的1只「假面英雄」怪兽为对象才能发动。那只怪兽无视召唤条件守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡1回合只有1次不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetCountLimit(1)
	e3:SetValue(s.indct)
	c:RegisterEffect(e3)
	-- ③：自己结束阶段，以自己墓地1张「变化」速攻魔法卡为对象才能发动。那张卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"盖放"
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 过滤条件：炎属性以外、墓地或除外状态的「假面英雄」怪兽，且可以无视召唤条件以守备表示特殊召唤
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and not c:IsAttribute(ATTRIBUTE_FIRE) and c:IsSetCard(0xa008) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_DEFENCE)
end
-- ①效果的靶向与发动检测：检查是否存在符合特召条件的炎属性以外的墓地/除外「假面英雄」怪兽，且自身怪兽区域有空位
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地或除外状态中是否存在符合条件的「假面英雄」怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择并锁定一只符合条件的墓地或除外状态的「假面英雄」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，包含特殊召唤分类、目标卡片组、数量等
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的效果处理：将选择的对象怪兽无视召唤条件守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被锁定的第一个效果对象
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡片仍存在于原本位置（未离开墓地/除外区）且不受「王家之谷」的影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽无视召唤条件以守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP_DEFENCE)
	end
end
-- ②效果的破坏判定：过滤战斗或效果破坏的破坏原因
function s.indct(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- ③效果的发动条件：必须是自己的结束阶段
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 过滤条件：墓地中的「变化」速攻魔法卡，且该卡可以在场上盖放
function s.sfilter(c)
	return c:IsSetCard(0xa5) and c:IsType(TYPE_QUICKPLAY) and c:IsSSetable()
end
-- ③效果的靶向与发动检测：检查自己魔法与陷阱区域是否有空位，且墓地中是否存在符合条件的「变化」速攻魔法卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sfilter(chkc) end
	-- 检查自己场上是否有可用的魔法与陷阱区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地中是否存在符合条件的「变化」速攻魔法卡
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择并锁定一张符合条件的墓地中的「变化」速攻魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将卡片移出墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ③效果的效果处理：将选择的「变化」速攻魔法卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上已无魔法与陷阱区域空格，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 获取当前连锁中被锁定的第一个效果对象
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡片仍存在于墓地且不受「王家之谷」的影响，将其在自己场上盖放
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then Duel.SSet(tp,tc) end
end
