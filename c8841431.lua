--騎士皇プリメラ・プリムス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己的卡组·墓地把1张「徽记」卡加入手卡。那之后，可以把自己以及对方场上的卡各1张破坏。
-- ②：从额外卡组以外特殊召唤的这张卡不会被战斗破坏。
-- ③：自己场上的表侧表示的「百夫长骑士」卡因对方的效果从场上离开的场合才能发动。这张卡从墓地特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册同调召唤手续、同调召唤成功时检索并可选破坏的效果、非额外卡组特召不被战破的效果，以及己方百夫长骑士卡因对方效果离场时墓地特召的效果。
function s.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从自己的卡组·墓地把1张「徽记」卡加入手卡。那之后，可以把自己以及对方场上的卡各1张破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thdcon)
	e1:SetTarget(s.thdtg)
	e1:SetOperation(s.thdop)
	c:RegisterEffect(e1)
	-- ②：从额外卡组以外特殊召唤的这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己场上的表侧表示的「百夫长骑士」卡因对方的效果从场上离开的场合才能发动。这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 检查此卡是否是通过同调召唤的方式特殊召唤，作为效果①的发动条件。
function s.thdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤卡组或墓地中属于「徽记」系列且能加入手牌的卡片。
function s.thfilter(c)
	return c:IsSetCard(0x1b3) and c:IsAbleToHand()
end
-- 效果①的发动准备与合法性检测，声明操作信息为将卡片从卡组或墓地加入手牌。
function s.thdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地中是否存在至少1张满足条件的「徽记」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁处理的操作信息，表示将从卡组或墓地把1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的处理逻辑：从卡组或墓地检索1张「徽记」卡，之后可选择破坏己方和对方场上的各1张卡。
function s.thdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张满足条件的「徽记」卡（受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 如果成功将选中的卡片加入手牌。
		if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			-- 向对方玩家展示加入手牌的卡片。
			Duel.ConfirmCards(1-tp,g)
			-- 获取自己场上的所有卡片。
			local g1=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
			-- 获取对方场上的所有卡片。
			local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
			-- 如果双方场上都存在卡片，询问玩家是否选择执行破坏效果。
			if #g1*#g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡破坏？"
				-- 提示玩家选择自己场上要破坏的卡片。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				local dg1=g1:Select(tp,1,1,nil)
				-- 提示玩家选择对方场上要破坏的卡片。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				local dg2=g2:Select(tp,1,1,nil)
				dg1:Merge(dg2)
				-- 闪烁显示选中的双方场上待破坏的卡片。
				Duel.HintSelection(dg1)
				-- 中断当前效果处理，使后续的破坏处理与加入手牌不视为同时进行。
				Duel.BreakEffect()
				-- 破坏选中的双方场上的卡片。
				Duel.Destroy(dg1,REASON_EFFECT)
			end
		end
	end
end
-- 效果②的启用条件：检查此卡是否是从额外卡组以外的区域特殊召唤。
function s.indcon(e)
	return e:GetHandler():GetSummonLocation()~=0 and not e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- 过滤因对方效果从自己场上离开的表侧表示「百夫长骑士」卡片。
function s.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousSetCard(0x1a2)
		and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- 效果③的发动条件：检查是否有满足条件的「百夫长骑士」卡片因对方效果离场，且离场卡片中不包含此卡自身。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,rp) and not eg:IsContains(e:GetHandler())
end
-- 效果③的发动准备与合法性检测，检查怪兽区域是否有空位以及此卡是否能特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位，且此卡是否可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息，表示将特殊召唤此卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的处理逻辑：将墓地的此卡特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与效果相关，且不受王家长眠之谷的影响。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将此卡以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
