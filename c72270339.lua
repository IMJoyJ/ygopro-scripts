--黒魔女ディアベルスター
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：这张卡可以把自己的手卡·场上1张卡送去墓地，从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「罪宝」魔法·陷阱卡在自己场上盖放。
-- ③：这张卡在对方回合从手卡·场上送去墓地的场合才能发动。从自己的手卡·场上把1张卡送去墓地，这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果：①手卡特召规则、②召唤·特召成功时盖放罪宝魔陷、③对方回合从手卡·场上送墓时送墓卡片特召自身
function s.initial_effect(c)
	-- ①：这张卡可以把自己的手卡·场上1张卡送去墓地，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.sprcon)
	e1:SetTarget(s.sprtg)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「罪宝」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡在对方回合从手卡·场上送去墓地的场合才能发动。从自己的手卡·场上把1张卡送去墓地，这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.rvcon)
	e4:SetTarget(s.rvtg)
	e4:SetOperation(s.rvop)
	c:RegisterEffect(e4)
end
-- 过滤函数：检查卡片是否满足过滤条件f，且将其送去墓地后，自己场上是否有可用的怪兽区域
function s.cfilter(c,tp,f)
	-- 返回卡片是否满足过滤条件f，且该卡离开场上后是否能空出至少1个怪兽区域
	return f(c) and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件判断函数
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己的手卡或场上是否存在至少1张可以作为Cost送去墓地的卡（不包括这张卡自身）
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,c,tp,Card.IsAbleToGraveAsCost)
end
-- 特殊召唤规则的消耗（Cost）选择目标函数
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己手卡·场上所有可以作为Cost送去墓地且满足怪兽区域空位要求的卡片组
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c,tp,Card.IsAbleToGraveAsCost)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的实际操作函数
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡作为特殊召唤的消耗（Cost）送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
-- 过滤函数：检查是否为「罪宝」魔法·陷阱卡，且可以盖放在场上
function s.filter(c)
	return c:IsSetCard(0x19e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果②盖放效果的发动准备（Target）函数
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以盖放的「罪宝」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果②盖放效果的实际处理（Operation）函数
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足条件的「罪宝」魔法·陷阱卡
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 若成功选出卡片，则将其在自己场上盖放
	if tc then Duel.SSet(tp,tc) end
end
-- 效果③特殊召唤效果的发动条件判断函数
function s.rvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否在对方回合从自己的手卡或场上送去墓地
	return c:IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD) and c:IsPreviousControler(tp) and Duel.GetTurnPlayer()==1-tp
end
-- 效果③特殊召唤效果的发动准备（Target）函数
function s.rvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己手卡·场上是否有可以送去墓地的卡，且这张卡是否可以特殊召唤
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp,Card.IsAbleToGrave)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息：预计将自己手卡或场上的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
	-- 设置连锁信息：预计将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果③特殊召唤效果的实际处理（Operation）函数
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己手卡或场上的1张卡送去墓地
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp,Card.IsAbleToGrave)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	-- 若成功将选中的卡送去墓地，且这张卡仍在连锁中，则继续处理
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) and c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
