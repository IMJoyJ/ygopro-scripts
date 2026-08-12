--決戦のゴルゴンダ
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「大沙海 黄金戈尔工达」使用。
-- ②：1回合1次，自己场上的卡被战斗·效果破坏的场合，可以作为代替从额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽送去墓地。
-- ③：自己·对方的结束阶段，自己的场上或墓地有「阿不思的落胤」存在的场合才能发动。从手卡·卡组把1只「护宝炮妖」怪兽特殊召唤。
function c70485614.initial_effect(c)
	-- 注册卡片记有「阿不思的落胤」卡名的信息
	aux.AddCodeList(c,68468459)
	-- 使这张卡在魔法与陷阱区域、墓地存在时卡名当作「大沙海 黄金戈尔工达」使用
	aux.EnableChangeCode(c,60884672,LOCATION_SZONE+LOCATION_GRAVE)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ②：1回合1次，自己场上的卡被战斗·效果破坏的场合，可以作为代替从额外卡组把以「阿不思的落胤」为融合素材的1只融合怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c70485614.reptg)
	e1:SetValue(c70485614.repval)
	e1:SetOperation(c70485614.repop)
	c:RegisterEffect(e1)
	-- ③：自己·对方的结束阶段，自己的场上或墓地有「阿不思的落胤」存在的场合才能发动。从手卡·卡组把1只「护宝炮妖」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70485614,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,70485614)
	e2:SetCondition(c70485614.spcon)
	e2:SetTarget(c70485614.sptg)
	e2:SetOperation(c70485614.spop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上因战斗或效果破坏的卡（不含代替破坏）
function c70485614.dfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 过滤额外卡组中以「阿不思的落胤」为融合素材且能送去墓地的融合怪兽
function c70485614.repfilter(c)
	-- 检查卡片是否为融合怪兽、是否以「阿不思的落胤」为融合素材，以及是否能送去墓地
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459) and c:IsAbleToGrave()
end
-- 代替破坏效果的靶指向/发动准备函数，检查是否有自己场上的卡被破坏，以及额外卡组是否有可送去墓地的代替卡
function c70485614.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c70485614.dfilter,1,nil,tp)
		-- 检查自己额外卡组是否存在至少1只满足条件的融合怪兽
		and Duel.IsExistingMatchingCard(c70485614.repfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定该代替破坏效果适用于自己场上被破坏的卡
function c70485614.repval(e,c)
	return c70485614.dfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的执行函数，从额外卡组选择1只满足条件的融合怪兽送去墓地
function c70485614.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从额外卡组选择1只以「阿不思的落胤」为融合素材的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c70485614.repfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 发送卡片提示，显示这张卡（决战的戈尔工达）的效果正在适用
	Duel.Hint(HINT_CARD,0,70485614)
	-- 将选中的怪兽作为代替破坏送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE)
end
-- 过滤场上表侧表示或墓地存在的「阿不思的落胤」
function c70485614.cfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCode(68468459)
end
-- 特殊召唤效果的发动条件函数，检查场上或墓地是否存在「阿不思的落胤」
function c70485614.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的场上或墓地是否存在至少1张「阿不思的落胤」
	return Duel.IsExistingMatchingCard(c70485614.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
-- 过滤手卡或卡组中可以特殊召唤的「护宝炮妖」怪兽
function c70485614.spfilter(c,e,tp)
	return c:IsSetCard(0x155) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的靶指向/发动准备函数，检查怪兽区域是否有空位以及手卡或卡组是否有可特殊召唤的怪兽
function c70485614.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在至少1只可以特殊召唤的「护宝炮妖」怪兽
		and Duel.IsExistingMatchingCard(c70485614.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示将从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果的执行函数，从手卡或卡组将1只「护宝炮妖」怪兽特殊召唤
function c70485614.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的主要怪兽区域是否已无空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只「护宝炮妖」怪兽
	local g=Duel.SelectMatchingCard(tp,c70485614.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
