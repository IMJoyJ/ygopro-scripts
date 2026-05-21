--創星竜華－光巴
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从卡组把灵摆怪兽以外的1张「龙华」卡加入手卡。那之后，这张卡破坏。
-- 【怪兽效果】
-- 「创星龙华-光巴」降临
-- 这张卡用这张卡的效果才能特殊召唤。自己对「创星龙华-光巴」1回合只能有1次特殊召唤。
-- ①：这张卡在额外卡组存在的状态，场上的怪兽被战斗·效果破坏的场合才能发动。自己场上1只10星「龙华」怪兽解放，这张卡当作仪式召唤作特殊召唤。那之后，以下可以适用。
-- ●自己场上最多2张卡破坏，把最多有那个数量的「龙华」永续魔法卡从卡组到自己场上表侧表示放置。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包括同名卡特召限制、苏生限制、灵摆属性、灵摆效果和怪兽效果
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	-- 注册灵摆怪兽的灵摆属性（灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- 这张卡用这张卡的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- ①：自己主要阶段才能发动。从卡组把灵摆怪兽以外的1张「龙华」卡加入手卡。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ①：这张卡在额外卡组存在的状态，场上的怪兽被战斗·效果破坏的场合才能发动。自己场上1只10星「龙华」怪兽解放，这张卡当作仪式召唤作特殊召唤。那之后，以下可以适用。●自己场上最多2张卡破坏，把最多有那个数量的「龙华」永续魔法卡从卡组到自己场上表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「龙华」卡（灵摆怪兽除外）且能加入手牌的卡片过滤函数
function s.thfilter(c)
	return c:IsSetCard(0x1c0) and c:IsAbleToHand()
		and not c:IsType(TYPE_PENDULUM)
end
-- 灵摆效果的发动准备与合法性检查（Target阶段），检查卡组中是否存在可检索的卡，并设置检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果的处理逻辑（Operation阶段）：检索卡片加入手牌，然后将自身破坏
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToEffect(e) then
			-- 中断当前效果处理，使后续的破坏处理与前面的检索处理不视为同时进行（避免时点问题）
			Duel.BreakEffect()
			-- 将此卡（灵摆区域的自身）因效果破坏
			Duel.Destroy(c,REASON_EFFECT)
		end
	end
end
-- 过滤因战斗或效果被破坏且原本在怪兽区域的卡片
function s.spcfilter(c)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 触发条件检查：场上的怪兽（除自身外）被战斗·效果破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spcfilter,1,e:GetHandler())
end
-- 过滤自己场上可被效果解放的10星「龙华」怪兽，且解放后能腾出足够的额外卡组特召怪兽区域
function s.rfilter(c,tp,ec)
	return c:IsSetCard(0x1c0) and c:IsReleasableByEffect()
		and c:IsLevel(10) and c:IsType(TYPE_MONSTER)
		-- 检查在解放该怪兽后，是否能腾出可供从额外卡组特殊召唤该卡的空间
		and Duel.GetLocationCountFromEx(tp,tp,c,ec)>0
end
-- 怪兽效果的发动准备与合法性检查（Target阶段），检查是否有可解放的怪兽以及自身是否能特召，并设置解放和特召的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己场上所有满足解放条件的10星「龙华」怪兽
	local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_MZONE,0,c,tp,c)
	if chk==0 then return #g>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true) end
	-- 设置当前连锁的操作信息为：解放场上的1张卡
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
	-- 设置当前连锁的操作信息为：特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤可破坏的卡，要求破坏后能腾出魔法与陷阱区域，或者该卡本身就在非场地魔法区域的魔法与陷阱区域
function s.desfilter(c,tp)
	-- 检查自己魔陷区是否有空位，或者被选中的卡本身就在魔陷区（且不是场地魔法卡），以确保后续能放置永续魔法
	return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or c:IsLocation(LOCATION_SZONE) and not c:IsLocation(LOCATION_FZONE)
end
-- 检查选中的破坏卡片组中，是否至少有1张卡满足腾出魔陷区或本身在魔陷区的条件
function s.gcheck1(g,tp)
	return g:IsExists(s.desfilter,1,nil,tp)
end
-- 过滤卡组中可以表侧表示放置到场上的「龙华」永续魔法卡
function s.pfilter(c,tp)
	return bit.band(c:GetType(),TYPE_SPELL+TYPE_CONTINUOUS)==TYPE_SPELL+TYPE_CONTINUOUS
		and c:IsSetCard(0x1c0)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 检查选中的永续魔法卡数量是否不超过自己场上可用的魔陷区空格数
function s.gcheck2(g,tp)
	-- 检查选中的卡片数量是否小于或等于当前可用的魔陷区空格数
	return g:GetCount()<=Duel.GetLocationCount(tp,LOCATION_SZONE)
end
-- 怪兽效果的处理逻辑（Operation阶段）：解放怪兽，将自身当作仪式召唤特殊召唤，并根据玩家选择适用后续的破坏与放置永续魔法效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给玩家发送提示信息，提示选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择1只自己场上的10星「龙华」怪兽作为解放对象
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_MZONE,0,1,1,aux.ExceptThisCard(e),tp,c)
	-- 如果成功解放目标怪兽，且此卡仍与效果关联，则将此卡当作仪式召唤特殊召唤到场上
	if Duel.Release(g,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
		-- 检查自己场上是否存在可破坏的卡（以确保能腾出魔陷区或本身在魔陷区）
		if Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
			-- 并且检查卡组中是否存在可放置的「龙华」永续魔法卡
			and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK,0,1,nil,tp)
			-- 询问玩家是否选择适用后续的破坏并放置永续魔法的效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡破坏？"
			-- 中断当前效果处理，使后续的破坏与放置处理与前面的特殊召唤不视为同时进行
			Duel.BreakEffect()
			-- 获取自己场上所有的卡片
			local rg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
			-- 给玩家发送提示信息，提示选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=rg:SelectSubGroup(tp,s.gcheck1,false,1,2,tp)
			-- 破坏选中的卡片，并返回实际破坏的数量
			local ct=Duel.Destroy(sg,REASON_EFFECT)
			-- 如果成功破坏了至少1张卡，且此时魔陷区有空位
			if ct>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
				if ct>2 then ct=2 end
				-- 获取卡组中所有满足条件的「龙华」永续魔法卡
				local dg=Duel.GetMatchingGroup(s.pfilter,tp,LOCATION_DECK,0,nil,tp)
				-- 给玩家发送提示信息，提示选择要放置到场上的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
				local pg=dg:SelectSubGroup(tp,s.gcheck2,false,1,ct,tp)
				-- 遍历选中的要放置的永续魔法卡
				for tc in aux.Next(pg) do
					-- 将选中的永续魔法卡在自己的魔法与陷阱区域表侧表示放置，并立刻适用其效果
					Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				end
			end
		end
	end
end
