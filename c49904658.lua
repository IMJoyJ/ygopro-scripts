--久遠の神徒フリムニル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己的手卡·场上3只天使族怪兽解放才能发动。从卡组把1张永续魔法卡在自己场上盖放。这个效果盖放的卡在对方结束阶段送去墓地。
-- ②：这张卡被效果送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化并注册这张卡的两个效果：e1为①的起动效果（在怪兽区域发动，1回合1次，以解放自己手卡·场上3只天使族怪兽为代价从卡组盖放永续魔法卡），e2为②的诱发选发效果（这张卡被效果送去墓地的场合发动，将自身特殊召唤，1回合1次）
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把自己的手卡·场上3只天使族怪兽解放才能发动。从卡组把1张永续魔法卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sttg)
	e1:SetOperation(s.stop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查这张卡可以解放、是天使族，且为自己控制（如手卡中的卡）或者表侧表示（如场上的卡）
function s.filter(c,tp)
	return c:IsReleasable() and c:IsRace(RACE_FAIRY) and (c:IsControler(tp) or c:IsFaceup())
end
-- 子组合检查函数：验证选出的解放组合可行，即解放这组卡后魔法与陷阱区域仍有空位，且组合中的卡都可作为代价解放
function s.rcheck(g,tp)
	-- 检查除去这组卡后自己的魔法与陷阱区域还有空格子，且这组卡全部属于可作为代价解放的卡
	return Duel.GetSZoneCount(tp,g)>0 and Duel.CheckReleaseGroupEx(tp,Auxiliary.IsInGroup,#g,REASON_COST,true,nil,g)
end
-- ①效果的代价处理：筛选手卡·场上可解放的天使族怪兽，确认能选出3只满足条件的组合，再让玩家选择3只并作为代价解放
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡·场上所有可解放的卡中满足天使族等条件的卡片组rg
	local rg=Duel.GetReleaseGroup(tp,true,REASON_COST):Filter(s.filter,nil,tp)
	if chk==0 then return rg:CheckSubGroup(s.rcheck,3,3,tp) end
	-- 向玩家提示“请选择要解放的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local g=rg:SelectSubGroup(tp,s.rcheck,false,3,3,tp)
	-- 消耗组合中代替解放类效果（如暗影敌托邦）的使用次数
	aux.UseExtraReleaseCount(g,tp)
	-- 把选出的3只天使族怪兽作为效果的代价解放
	Duel.Release(g,REASON_COST)
end
-- 过滤函数：检查这张卡是永续魔法卡且可以盖放到魔法与陷阱区域
function s.stfilter(c)
	return c:IsAllTypes(TYPE_CONTINUOUS+TYPE_SPELL) and c:IsSSetable()
end
-- ①效果的发动条件检查：自己的魔法与陷阱区域有空位，且卡组存在可以盖放的永续魔法卡
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己的魔法与陷阱区域有1个以上空位，且卡组里至少有1张可以盖放的永续魔法卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果的处理：从卡组选1张永续魔法卡在自己场上盖放，盖放成功后为那张卡注册标记，并注册一个在对方结束阶段把那张卡送去墓地的持续效果
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己的魔法与陷阱区域没有空位则中止效果处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向玩家提示“请选择要盖放的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张可以盖放的永续魔法卡
	local g=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的永续魔法卡在自己的魔法与陷阱区域盖放
		local ct=Duel.SSet(tp,g)
		if ct~=0 then
			local tc=g:GetFirst()
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
			-- 这个效果盖放的卡在对方结束阶段送去墓地。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.tgcon)
			e1:SetOperation(s.tgop)
			-- 把这个结束阶段送去墓地的持续效果注册为全局环境效果
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 送墓效果的适用条件：当前是对方的结束阶段，且盖放的那张卡仍带有本效果对应的标记，否则重置此效果
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前回合玩家不是对方（即不是对方的结束阶段），则不满足条件
	if Duel.GetTurnPlayer()~=1-tp then return false end
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 处理：把记录的那张盖放的卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因把那张盖放的卡送去墓地
	Duel.SendtoGrave(tc,REASON_EFFECT)
end
-- ②效果的发动条件：检查这张卡是被效果（含重定向代替）送去墓地的
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT+REASON_REDIRECT)
end
-- ②效果的发动条件检查：自己的主要怪兽区域有空位，且这张卡可以被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己的主要怪兽区域有1个以上空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本连锁将特殊召唤这张卡1张，供星尘龙、王家长眠之谷等效果检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：确认这张卡仍与本连锁关联且不受王家长眠之谷影响后，将其以表侧表示特殊召唤，成功后为其注册“从场上离开的场合除外”的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡与此连锁仍有关联、不受王家长眠之谷影响，且以表侧表示特殊召唤成功
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
