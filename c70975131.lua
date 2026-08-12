--番猫－ウォッチキャット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤成功的自己回合的结束阶段把场上的这张卡除外才能发动。从卡组选1张永续魔法卡在自己的魔法与陷阱区域盖放。
function c70975131.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70975131,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,70975131)
	e1:SetCondition(c70975131.spcon)
	e1:SetTarget(c70975131.sptg)
	e1:SetOperation(c70975131.spop)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤成功
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c70975131.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤成功的自己回合的结束阶段把场上的这张卡除外才能发动。从卡组选1张永续魔法卡在自己的魔法与陷阱区域盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(70975131,1))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,70975132)
	e3:SetCondition(c70975131.setcon)
	-- 把场上的这张卡除外作为发动的代价（Cost）
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c70975131.settg)
	e3:SetOperation(c70975131.setop)
	c:RegisterEffect(e3)
end
-- 特殊召唤效果的发动条件判定函数
function c70975131.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在怪兽，若没有怪兽则返回true
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 特殊召唤效果的发动准备与合法性检查函数
function c70975131.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动检查时，确认自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的执行函数
function c70975131.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 特殊召唤成功时，为自身注册一个持续到回合结束的标记（Flag）
function c70975131.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(70975131,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 盖放效果的发动条件判定函数
function c70975131.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否带有特殊召唤成功的标记，且当前回合是自己的回合
	return e:GetHandler():GetFlagEffect(70975131)~=0 and Duel.GetTurnPlayer()==tp
end
-- 过滤卡组中可盖放的永续魔法卡
function c70975131.setfilter(c)
	return c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsSSetable()
end
-- 盖放效果的发动准备与合法性检查函数
function c70975131.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认自己场上是否有可用的魔法与陷阱区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 在发动检查时，确认卡组中是否存在可以盖放的永续魔法卡
		and Duel.IsExistingMatchingCard(c70975131.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 盖放效果的执行函数
function c70975131.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，若自己场上已无空余的魔法与陷阱区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 在客户端弹出提示，要求玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组中选择1张满足条件的永续魔法卡
	local g=Duel.SelectMatchingCard(tp,c70975131.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的永续魔法卡在自己的魔法与陷阱区域盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
