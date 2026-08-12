--聖騎士モルドレッド
-- 效果：
-- ①：这张卡只要在怪兽区域存在，当作通常怪兽使用。
-- ②：只要这张卡有「圣剑」装备魔法卡装备，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡等级上升1星并变成暗属性。
-- ●1回合1次，自己场上没有这张卡以外的怪兽存在的场合才能发动。从卡组把「圣骑士 莫德雷德」以外的1只「圣骑士」怪兽守备表示特殊召唤，选自己场上1张装备魔法卡破坏。
function c59057152.initial_effect(c)
	-- ①：这张卡只要在怪兽区域存在，当作通常怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c59057152.eqcon1)
	e1:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_REMOVE_TYPE)
	e2:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e2)
	-- ●这张卡等级上升1星并变成暗属性。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c59057152.eqcon2)
	e3:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_LEVEL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ●1回合1次，自己场上没有这张卡以外的怪兽存在的场合才能发动。从卡组把「圣骑士 莫德雷德」以外的1只「圣骑士」怪兽守备表示特殊召唤，选自己场上1张装备魔法卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(59057152,0))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c59057152.spcon)
	e5:SetTarget(c59057152.sptg)
	e5:SetOperation(c59057152.spop)
	c:RegisterEffect(e5)
end
-- 定义条件函数：判断这张卡是否没有装备「圣剑」装备魔法卡
function c59057152.eqcon1(e)
	local eg=e:GetHandler():GetEquipGroup()
	return not eg or not eg:IsExists(Card.IsSetCard,1,nil,0x207a)
end
-- 定义条件函数：判断这张卡是否有装备「圣剑」装备魔法卡
function c59057152.eqcon2(e)
	local eg=e:GetHandler():GetEquipGroup()
	return eg and eg:IsExists(Card.IsSetCard,1,nil,0x207a)
end
-- 定义发动条件函数：自身有装备「圣剑」且自己场上没有其他怪兽
function c59057152.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足：有装备「圣剑」且自己场上的怪兽数量为1（即只有这张卡自身）
	return c59057152.eqcon2(e) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
-- 过滤卡组中「圣骑士 莫德雷德」以外的「圣骑士」怪兽，且该怪兽可以守备表示特殊召唤
function c59057152.spfilter(c,e,tp)
	return c:IsSetCard(0x107a) and not c:IsCode(59057152) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 定义效果发动准备函数：检查怪兽区域是否有空位、卡组中是否有可特召的怪兽，并设置操作信息
function c59057152.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，判断自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且卡组中存在至少1只满足特召过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c59057152.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤场上表侧表示的装备魔法卡
function c59057152.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsType(TYPE_SPELL)
end
-- 定义效果处理函数：从卡组特殊召唤1只「圣骑士」怪兽，并破坏自己场上1张装备魔法卡
function c59057152.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足特召条件的「圣骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c59057152.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 若成功选择怪兽，则将其以表侧守备表示特殊召唤，并在特殊召唤成功时执行后续处理
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 提示玩家选择要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家从自己的魔法与陷阱区域选择1张装备魔法卡
		local dg=Duel.SelectMatchingCard(tp,c59057152.desfilter,tp,LOCATION_SZONE,0,1,1,nil)
		-- 因效果破坏所选的装备魔法卡
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
