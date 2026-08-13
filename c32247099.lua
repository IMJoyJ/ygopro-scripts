--絶対なる幻神獣
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时，从手卡丢弃1张魔法·陷阱卡，以自己墓地1只幻神兽族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。那之后，攻击对象转移为那只怪兽。
-- ②：自己场上有幻神兽族怪兽存在的场合，结束阶段才能发动。把这个回合在场上让效果发动的对方场上的表侧表示的卡全部破坏。
function c32247099.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方怪兽的攻击宣言时，从手卡丢弃1张魔法·陷阱卡，以自己墓地1只幻神兽族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。那之后，攻击对象转移为那只怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32247099,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,32247099)
	e2:SetCondition(c32247099.spcon)
	e2:SetCost(c32247099.spcost)
	e2:SetTarget(c32247099.sptg)
	e2:SetOperation(c32247099.spop)
	c:RegisterEffect(e2)
	-- ②：自己场上有幻神兽族怪兽存在的场合，结束阶段才能发动。把这个回合在场上让效果发动的对方场上的表侧表示的卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32247099,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,32247100)
	e3:SetCondition(c32247099.descon)
	e3:SetTarget(c32247099.destg)
	e3:SetOperation(c32247099.desop)
	c:RegisterEffect(e3)
	if not c32247099.global_check then
		c32247099.global_check=true
		-- 把这个回合在场上让效果发动的对方场上的表侧表示的卡全部破坏。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(c32247099.checkop1)
		-- 注册一个全局持续效果，监听任意效果的发动，为发动过效果的卡累计标记，供②效果识别“这个回合在场上让效果发动的对方场上的表侧表示的卡”。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_CHAIN_NEGATED)
		ge2:SetOperation(c32247099.checkop2)
		-- 注册另一个全局持续效果，监听连锁被无效的事件，在效果被无效时减少对应卡的标记数，以保证被无效的发动不计入②效果的破坏对象。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 定义“效果发动时”的处理：每当任意卡发动效果，若发动卡与效果关联，则给该卡添加或累加一个专用标记，记录其本回合在场上发动过效果，该标记会持续到回合结束/离场等重置时机。
function c32247099.checkop1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) then
		local ct=rc:GetFlagEffectLabel(32247099)
		if not ct then
			rc:RegisterFlagEffect(32247099,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,1)
		else
			rc:SetFlagEffectLabel(32247099,ct+1)
		end
	end
end
-- 定义“连锁被无效时”的处理：若一张卡的效果发动被无效，则将其标记数减1；若标记减到0则移除标记，从而准确筛选“本回合发动过效果”的卡。
function c32247099.checkop2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local ct=rc:GetFlagEffectLabel(32247099)
	if ct==1 then
		rc:ResetFlagEffect(32247099)
	elseif ct then
		rc:SetFlagEffectLabel(32247099,ct-1)
	end
end
-- 定义①效果的发动条件：发生攻击宣言时，且攻击怪兽是对方怪兽（当前攻击怪兽控制者为对方玩家）才满足条件。
function c32247099.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击宣言的怪兽是否由对方玩家控制，实现“对方怪兽的攻击宣言时”的限定。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 定义①效果丢弃代价的筛选条件：手卡中的魔法·陷阱卡且可以被丢弃。
function c32247099.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable()
end
-- 定义①效果的发动代价：从手卡选择丢弃1张满足条件的魔法·陷阱卡；在chk==0时先确认存在可丢弃的卡，处理时执行丢弃。
function c32247099.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查阶段：确认手卡中存在至少1张可以丢弃的魔法·陷阱卡，否则效果无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c32247099.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：让玩家从手卡选择1张魔法·陷阱卡丢弃，丢弃原因是作为发动代价（REASON_COST+REASON_DISCARD）。
	Duel.DiscardHand(tp,c32247099.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义可选择为特殊召唤对象的条件：自己墓地的幻神兽族怪兽，且能够以表侧守备表示特殊召唤。
function c32247099.spfilter(c,e,tp)
	return c:IsRace(RACE_DIVINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 定义①效果的目标选择：必须选择自己墓地1只符合spfilter的幻神兽族怪兽作为对象，同时确认主怪兽区有空位；若chkc参数存在，则验证该卡是否为合法对象。
function c32247099.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32247099.spfilter(chkc,e,tp) end
	-- 合法性检查：确认自己的主怪兽区域存在至少1个空位，可用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 合法性检查：确认自己墓地存在至少1只符合条件的幻神兽族怪兽，且能够成为效果对象。
		and Duel.IsExistingTarget(c32247099.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送“选择要特殊召唤的卡”的提示信息，用于后续Duel.SelectTarget的选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让当前玩家从自己墓地选择1只符合条件的幻神兽族怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c32247099.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：声明本效果将进行1只怪兽的特殊召唤，对象为已选择的卡g，供后续连锁反应和效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义①效果的处理流程：将选择的对象怪兽表侧守备表示特殊召唤；若特殊召唤成功且攻击怪兽不免疫此效果，则中断当前处理并将攻击对象改为那只怪兽。
function c32247099.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动效果时选择的那只对象怪兽（墓地中的幻神兽族怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联（未离开墓地），并尝试将其以表侧守备表示特殊召唤；若特殊召唤成功则继续后续判断。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0
		-- 进一步判断攻击宣言的怪兽是否对此效果免疫；若免疫，则不能强制将其攻击对象转移。
		and not Duel.GetAttacker():IsImmuneToEffect(e) then
		-- 中断当前效果处理，使后续“攻击对象转移”作为新的处理环节，避免与特殊召唤成功时点产生冲突（制造错时点）。
		Duel.BreakEffect()
		-- 把当前攻击对象的攻击目标转移为tc（特殊召唤成功的怪兽），完成“那之后，攻击对象转移为那只怪兽”。
		Duel.ChangeAttackTarget(tc)
	end
end
-- 定义②效果发动条件的判断：自己场上是否存在表侧表示且种族为幻神兽族的怪兽。
function c32247099.descfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DIVINE)
end
-- 定义②效果的发动条件：结束阶段时，自己场上有表侧表示的幻神兽族怪兽存在。
function c32247099.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自己场上是否存在至少1只表侧表示的幻神兽族怪兽，用于满足②效果的发动条件。
	return Duel.IsExistingMatchingCard(c32247099.descfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义②效果要破坏的卡的筛选条件：对方场上表侧表示，且带有“本回合发动过效果”标记（flag 32247099）的卡。
function c32247099.desfilter(c)
	return c:IsFaceup() and c:GetFlagEffect(32247099)>0
end
-- 定义②效果的目标：获取对方场上所有表侧表示且本回合发动过效果的卡，若有则设置破坏的操作信息。
function c32247099.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得对方场上所有表侧表示且带有效果发动标记的卡，形成要破坏的卡组g。
	local g=Duel.GetMatchingGroup(c32247099.desfilter,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置操作信息：声明本效果将破坏g中的#g张卡，破坏分类为CATEGORY_DESTROY，供连锁/效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 定义②效果的处理：再次获取符合条件的对方场上表侧表示且带标记的卡，然后全部破坏。
function c32247099.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 在处理阶段重新获取对方场上表侧表示且带标记的卡集合，以反映当前实际状态。
	local g=Duel.GetMatchingGroup(c32247099.desfilter,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		-- 将这些卡以效果破坏的方式全部送入墓地。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
