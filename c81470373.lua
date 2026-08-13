--BF－毒風のシムーン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上没有怪兽存在的场合，从手卡把这张卡以外的1只「黑羽」怪兽除外才能发动。从卡组选1张「黑旋风」在自己的魔法与陷阱区域表侧表示放置。那之后，手卡的这张卡不用解放作召唤或送去墓地。这个效果放置的「黑旋风」在结束阶段送去墓地，自己受到1000伤害。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化效果：注册手卡的起动效果e1（放置「黑旋风」并把这张卡不用解放作召唤或送去墓地），以及手卡的召唤规则效果e2（这张卡可以不用解放作通常召唤），并将e2设为e1的标签对象
function s.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，从手卡把这张卡以外的1只「黑羽」怪兽除外才能发动。从卡组选1张「黑旋风」在自己的魔法与陷阱区域表侧表示放置。那之后，手卡的这张卡不用解放作召唤或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.sumcon)
	e1:SetCost(s.sumcost)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	-- 手卡的这张卡不用解放作召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.ntcon)
	e2:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
-- 召唤规则效果的适用条件函数：这张卡可以不用解放作通常召唤
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 需要的解放数量为0且确认无需祭品即可通常召唤
	return minc==0 and Duel.CheckTribute(c,0)
end
-- 起动效果的发动条件函数
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 自己场上没有怪兽存在
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 代价过滤函数：这张卡以外的「黑羽」怪兽且可以作为代价除外
function s.cfilter(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果代价处理：从手卡把这张卡以外的1只「黑羽」怪兽除外
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡是否存在这张卡以外可以作为代价除外的「黑羽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c) end
	-- 向玩家提示请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡选择1只这张卡以外的「黑羽」怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 把选择的怪兽以表侧表示除外作为代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 「黑旋风」过滤函数：卡号为91351370（「黑旋风」）且未被禁止放置、满足场上同名卡只能有1张的限制
function s.acfilter(c,tp)
	return c:IsCode(91351370) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果能否发动的目标检查：魔陷区有空位、卡组有可放置的「黑旋风」，且这张卡可以不用解放作召唤或者可以送去墓地
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 自己的魔法与陷阱区域没有空位则不能发动
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0
			-- 卡组没有可放置的「黑旋风」则不能发动
			or not Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_DECK,0,1,nil,tp) then return false end
		return e:GetHandler():IsSummonable(true,e:GetLabelObject()) or e:GetHandler():IsAbleToGrave()
	end
end
-- 效果处理：注册额外卡组非暗属性怪兽的特殊召唤限制，从卡组把「黑旋风」在魔陷区表侧表示放置并注册结束阶段送墓与伤害效果，那之后把这张卡不用解放作召唤或送去墓地
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能从额外卡组特殊召唤。从卡组选1张「黑旋风」在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把不能特殊召唤非暗属性额外怪兽的限制效果注册给发动玩家
	Duel.RegisterEffect(e1,tp)
	-- 魔法与陷阱区域没有空位则中断效果处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向玩家提示请选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组选择1张「黑旋风」
	local tc=Duel.SelectMatchingCard(tp,s.acfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	-- 把选择的「黑旋风」在自己的魔法与陷阱区域表侧表示放置
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 这个效果放置的「黑旋风」在结束阶段送去墓地，自己受到1000伤害。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetOperation(s.tgop)
		tc:RegisterEffect(e1)
		if not c:IsRelateToEffect(e) then return end
		local se=e:GetLabelObject()
		if c:IsSummonable(true,se)
			-- 这张卡不能送去墓地，或者玩家选择了不用解放作召唤的选项（选项0）的场合
			and (not c:IsAbleToGrave() or Duel.SelectOption(tp,1151,1191)==0) then
			-- 中断当前效果处理，使召唤与前述处理视为不同时进行（对应原文的「那之后」）
			Duel.BreakEffect()
			-- 把这张卡不用解放作召唤
			Duel.Summon(tp,c,true,se)
		else
			-- 中断当前效果处理，使送去墓地与前述处理视为不同时进行
			Duel.BreakEffect()
			-- 把这张卡送去墓地
			Duel.SendtoGrave(c,REASON_EFFECT)
		end
	end
end
-- 特殊召唤限制：不是暗属性的怪兽不能从额外卡组特殊召唤
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK) and c:IsLocation(LOCATION_EXTRA)
end
-- 结束阶段处理：显示卡片提示后把这个效果放置的「黑旋风」送去墓地，成功的场合自己受到1000伤害
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示这张卡的发动提示动画（不入连锁的处理提示）
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	-- 成功把「黑旋风」送去墓地的场合
	if Duel.SendtoGrave(c,REASON_EFFECT)~=0 then
		-- 自己受到1000伤害
		Duel.Damage(tp,1000,REASON_EFFECT)
	end
end
