--妖精胞スポーア
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。这张卡的等级上升最多有自己场上的怪兽数量的数值。
-- ②：这张卡在墓地存在，自己场上有「古代妖精龙」或者兽族·植物族·天使族的光属性怪兽的其中任意种存在的场合才能发动。这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册该卡片的效果①（特殊召唤时上升等级）和效果②（墓地自身特召）
function s.initial_effect(c)
	-- 将「古代妖精龙」的卡片密码注册到该卡的关联卡片列表中
	aux.AddCodeList(c,25862681)
	-- ①：这张卡特殊召唤的场合才能发动。这张卡的等级上升最多有自己场上的怪兽数量的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.lvcon)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有「古代妖精龙」或者兽族·植物族·天使族的光属性怪兽的其中任意种存在的场合才能发动。这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。[这个卡名的②的效果1回合只能使用1次。]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：这张卡具有等级（大于等于0）
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLevelAbove(0)
end
-- 效果①的效果处理：让玩家宣言一个不超过自己场上怪兽数量的数值，使这张卡的等级上升该数值
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上的怪兽数量
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsType(TYPE_MONSTER) and ct>0 then
		-- 给玩家发送提示信息，提示选择要上升的等级
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要上升的等级"
		-- 让玩家宣言一个1到自己场上怪兽数量之间的等级数值
		local lv=Duel.AnnounceLevel(tp,1,ct)
		-- 这张卡的等级上升最多有自己场上的怪兽数量的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(lv)
		c:RegisterEffect(e1)
	end
end
-- 过滤条件：场上表侧表示的「古代妖精龙」或者兽族·植物族·天使族的光属性怪兽
function s.cfilter(c)
	return c:IsFaceupEx() and (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST+RACE_FAIRY+RACE_PLANT) and c:IsType(TYPE_MONSTER)
		or c:IsCode(25862681))
end
-- 效果②的发动条件：自己场上存在满足条件的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（不含自身）是否存在至少1张满足过滤条件s.cfilter的卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
-- 效果②的靶向处理（Target）：检查怪兽区域是否有空位，以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将特殊召唤1张墓地中的自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将自身特殊召唤，并适用“直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤”的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍存在于墓地（不受王家之谷影响）且效果关系成立
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将这张卡以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.limit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能从额外卡组特殊召唤同调怪兽以外的怪兽的限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能从额外卡组特殊召唤同调怪兽以外的怪兽
function s.limit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO)
end
