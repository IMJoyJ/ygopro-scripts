--ENウェーブ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的「元素英雄」怪兽成为融合怪兽的融合召唤的素材，被送去墓地的场合或者被除外的场合才能发动。从卡组把1只「新空间侠」怪兽或者「元素英雄 新宇侠」特殊召唤。
-- ②：「新空间侠」怪兽或者「元素英雄 新宇侠」从自己的场上·墓地回到自己的卡组·额外卡组的场合才能发动。从自己墓地选1只「元素英雄」怪兽特殊召唤。
local s,id,o=GetID()
-- 效果初始化注册函数，注册此卡的所有效果
function s.initial_effect(c)
	-- 记录此卡上记载的卡片密码「元素英雄 新宇侠」
	aux.AddCodeList(c,89943723)
	-- 记录此卡关联的怪兽系列「元素英雄」
	aux.AddSetNameMonsterList(c,0x3008)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己的「元素英雄」怪兽成为融合怪兽的融合召唤的素材，被送去墓地的场合或者被除外的场合才能发动。从卡组把1只「新空间侠」怪兽或者「元素英雄 新宇侠」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.dspcon)
	e1:SetTarget(s.dsptg)
	e1:SetOperation(s.dspop)
	c:RegisterEffect(e1)
	-- ②：「新空间侠」怪兽或者「元素英雄 新宇侠」从自己的场上·墓地回到自己的卡组·额外卡组的场合才能发动。从自己墓地选1只「元素英雄」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.gspcon)
	e2:SetTarget(s.gsptg)
	e2:SetOperation(s.gspop)
	c:RegisterEffect(e2)
end
-- 过滤自己的「元素英雄」怪兽且确实成为了融合素材送去墓地或被除外的怪兽
function s.dspconfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and not c:IsReason(REASON_RETURN)
		and (c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousSetCard(0x3008)
			or not c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsSetCard(0x3008))
end
-- 效果①的发动条件判定（是否自己「元素英雄」怪兽成为融合素材送去墓地或除外）
function s.dspcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_FUSION and eg:IsExists(s.dspconfilter,1,nil,tp)
end
-- 过滤卡组中可特殊召唤的「新空间侠」怪兽或者「元素英雄 新宇侠」
function s.dspfilter(c,e,tp)
	return (c:IsSetCard(0x1f) or c:IsCode(89943723)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与条件检查
function s.dsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的「新空间侠」怪兽或「元素英雄 新宇侠」
		and Duel.IsExistingMatchingCard(s.dspfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置在效果处理时从卡组特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理
function s.dspop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域，若无空余则效果处理结束
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择卡组中1只满足条件的「新空间侠」怪兽或「元素英雄 新宇侠」
	local g=Duel.SelectMatchingCard(tp,s.dspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己的「新空间侠」怪兽或「元素英雄 新宇侠」且确实从场上或墓地回到了卡组或额外卡组的卡片
function s.gspconfilter(c,tp)
	return ((c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1f)) or c:IsCode(89943723))
		and c:IsPreviousControler(tp) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_MZONE+LOCATION_GRAVE)
end
-- 效果②的发动条件判定（是否有「新空间侠」怪兽或「元素英雄 新宇侠」从自己场上·墓地回到卡组·额外卡组）
function s.gspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.gspconfilter,1,nil,tp)
end
-- 过滤自己墓地可特殊召唤的「元素英雄」怪兽
function s.gspfilter(c,e,tp)
	return c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与条件检查
function s.gsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中是否存在可以特殊召唤的「元素英雄」怪兽
		and Duel.IsExistingMatchingCard(s.gspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置在效果处理时从墓地特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理
function s.gspop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域，若无空余则效果处理结束
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中1只满足条件的「元素英雄」怪兽
	local g=Duel.SelectMatchingCard(tp,s.gspfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将墓地的「元素英雄」怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
