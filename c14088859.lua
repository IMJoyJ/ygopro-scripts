--ネオス・フュージョン
-- 效果：
-- ①：从自己的手卡·卡组·场上把融合怪兽卡决定的融合素材怪兽送去墓地，把只以包含「元素英雄 新宇侠」的怪兽2只为素材的那1只融合怪兽无视召唤条件从额外卡组特殊召唤。这张卡的发动后，直到回合结束时自己不能把怪兽特殊召唤。
-- ②：需以「元素英雄 新宇侠」为融合素材的自己场上的融合怪兽被战斗·效果破坏的场合或者因自身的效果回到额外卡组的场合，可以作为代替把墓地的这张卡除外。
function c14088859.initial_effect(c)
	-- 为卡片注册融合素材代码89943723，表示该卡效果中涉及「元素英雄 新宇侠」的融合素材
	aux.AddCodeList(c,89943723)
	-- 为卡片注册系列编码0x3008，用于判断是否为「元素英雄」系列怪兽
	aux.AddSetNameMonsterList(c,0x3008)
	-- ①：从自己的手卡·卡组·场上把融合怪兽卡决定的融合素材怪兽送去墓地，把只以包含「元素英雄 新宇侠」的怪兽2只为素材的那1只融合怪兽无视召唤条件从额外卡组特殊召唤。这张卡的发动后，直到回合结束时自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14088859,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c14088859.target)
	e1:SetOperation(c14088859.activate)
	c:RegisterEffect(e1)
	-- ②：需以「元素英雄 新宇侠」为融合素材的自己场上的融合怪兽被战斗·效果破坏的场合或者因自身的效果回到额外卡组的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c14088859.reptg)
	e2:SetValue(c14088859.repval)
	e2:SetOperation(c14088859.repop)
	c:RegisterEffect(e2)
	-- ②：需以「元素英雄 新宇侠」为融合素材的自己场上的融合怪兽被战斗·效果破坏的场合或者因自身的效果回到额外卡组的场合，可以作为代替把墓地的这张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_SEND_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(c14088859.reptg2)
	e3:SetOperation(c14088859.repop2)
	e3:SetValue(c14088859.repval2)
	c:RegisterEffect(e3)
end
-- 定义用于筛选可送入墓地的卡片的过滤函数，检查是否为怪兽卡且能送入墓地
function c14088859.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
-- 定义用于筛选可特殊召唤的融合怪兽的过滤函数，检查是否满足2只素材且包含「元素英雄 新宇侠」
function c14088859.filter2(c,e,tp,m,chkf)
	-- 获取融合怪兽所需最小和最大素材数量
	local min,max=aux.GetMaterialListCount(c)
	-- 检查融合怪兽是否恰好需要2只素材且包含「元素英雄 新宇侠」
	return min==2 and max==2 and aux.IsMaterialListCode(c,89943723)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:CheckFusionMaterial(m,nil,chkf,true)
end
-- 定义效果目标函数，用于判断是否可以发动此卡效果
function c14088859.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp|0x200
		-- 获取玩家手牌、场上和卡组中所有可送入墓地的卡片组
		local mg=Duel.GetMatchingGroup(c14088859.filter1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,nil,e)
		-- 检查是否存在满足条件的融合怪兽可特殊召唤
		return Duel.IsExistingMatchingCard(c14088859.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,chkf)
	end
	-- 设置连锁操作信息，表示将要特殊召唤1只融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义效果发动函数，用于处理卡的发动效果
function c14088859.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp|0x200
	-- 获取玩家手牌、场上和卡组中所有可送入墓地的卡片组
	local mg=Duel.GetMatchingGroup(c14088859.filter1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,nil,e)
	-- 获取满足条件的融合怪兽组
	local sg=Duel.GetMatchingGroup(c14088859.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,chkf)
	if sg:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 选择融合怪兽的融合素材
		local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf,true)
		-- 将融合素材送入墓地
		Duel.SendtoGrave(mat,REASON_EFFECT)
		-- 中断当前效果处理，使后续效果不同时处理
		Duel.BreakEffect()
		-- 将融合怪兽从额外卡组特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- ①：从自己的手卡·卡组·场上把融合怪兽卡决定的融合素材怪兽送去墓地，把只以包含「元素英雄 新宇侠」的怪兽2只为素材的那1只融合怪兽无视召唤条件从额外卡组特殊召唤。这张卡的发动后，直到回合结束时自己不能把怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		-- 注册效果，使玩家在本回合不能特殊召唤怪兽
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义用于判断是否可以作为代替破坏的融合怪兽的过滤函数
function c14088859.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_FUSION)
		-- 检查融合怪兽是否为「元素英雄 新宇侠」系列且因战斗或效果破坏
		and aux.IsMaterialListCode(c,89943723) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 定义用于判断是否发动代替破坏效果的函数
function c14088859.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c14088859.repfilter,1,nil,tp) end
	-- 提示玩家选择是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 定义用于判断代替破坏效果是否生效的函数
function c14088859.repval(e,c)
	return c14088859.repfilter(c,e:GetHandlerPlayer())
end
-- 定义代替破坏效果的处理函数
function c14088859.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡从墓地除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
-- 定义用于判断是否可以作为代替送入卡组的融合怪兽的过滤函数
function c14088859.repfilter2(c,tp,re)
	-- 检查融合怪兽是否为「元素英雄 新宇侠」系列且因自身效果回到额外卡组
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and aux.IsMaterialListCode(c,89943723) and c:IsType(TYPE_FUSION)
		and c:GetDestination()==LOCATION_DECK and re:GetOwner()==c
end
-- 定义用于判断是否发动代替送入卡组效果的函数
function c14088859.reptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return bit.band(r,REASON_EFFECT)~=0 and re
		and e:GetHandler():IsAbleToRemove() and eg:IsExists(c14088859.repfilter2,1,nil,tp,re) end
	-- 提示玩家选择是否发动代替送入卡组效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(14088859,1)) then  --"是否除外「新宇融合」作为代替？"
		return true
	else return false end
end
-- 定义代替送入卡组效果的处理函数
function c14088859.repop2(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡从墓地除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
-- 定义用于判断代替送入卡组效果是否生效的函数
function c14088859.repval2(e,c)
	-- 检查融合怪兽是否为「元素英雄 新宇侠」系列且在场上
	return c:IsControler(e:GetHandlerPlayer()) and c:IsLocation(LOCATION_MZONE) and aux.IsMaterialListCode(c,89943723) and c:IsType(TYPE_FUSION)
end
