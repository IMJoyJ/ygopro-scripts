--共鳴する振動
-- 效果：
-- ①：对方的灵摆区域有2张卡存在的场合，以那2张卡为对象才能发动。那2张卡在对方的灵摆区域存在，这个回合自己灵摆召唤的场合，可以用对方一组灵摆刻度来灵摆召唤。那个场合，不是从额外卡组中不能把怪兽灵摆召唤。
function c31531170.initial_effect(c)
	-- ①：对方的灵摆区域有2张卡存在的场合，以那2张卡为对象才能发动。那2张卡在对方的灵摆区域存在，这个回合自己灵摆召唤的场合，可以用对方一组灵摆刻度来灵摆召唤。那个场合，不是从额外卡组中不能把怪兽灵摆召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c31531170.target)
	e1:SetOperation(c31531170.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标处理：确认可发动条件（本回合未使用过本效果或存在其他额外灵摆召唤效果、对方灵摆区域有2张卡），选择对方灵摆区域的2张卡并设置为连锁对象。
function c31531170.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 初始化灵摆召唤使用记录表，若全局标记 aux.PendulumChecklist 尚不存在则置0，用于记录已使用过该额外灵摆召唤手续的玩家。
	if not aux.PendulumChecklist then aux.PendulumChecklist=0 end
	-- 发动合法性判定：我方本回合尚未通过此卡使用过额外灵摆召唤（或已有其他额外灵摆召唤效果存在），且对方灵摆区域存在至少2张卡可作为对象。
	if chk==0 then return (aux.PendulumChecklist&(0x1<<tp)==0 or Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)) and Duel.IsExistingTarget(nil,tp,0,LOCATION_PZONE,2,nil) end
	-- 获取对方灵摆区域当前存在的所有卡，组成一个卡片组 g。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_PZONE)
	-- 将卡片组 g 设置为当前连锁的对象（广义对象，即取对象效果指定的对象）。
	Duel.SetTargetCard(g)
end
-- 效果处理时：确认两张对象卡仍与效果关联且在对方灵摆区域；以其中1张卡为持有者注册一个额外的灵摆召唤手续效果，并互相用FlagEffect记录对方卡的FieldID作为配对标记。
function c31531170.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方灵摆区域左位（序号0）的卡作为第一张对象卡 tc1。
	local tc1=Duel.GetFieldCard(1-tp,LOCATION_PZONE,0)
	-- 获取对方灵摆区域右位（序号1）的卡作为第二张对象卡 tc2。
	local tc2=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
	if not tc1:IsRelateToEffect(e) or not tc2:IsRelateToEffect(e) then return end
	-- 这个回合自己灵摆召唤的场合，可以用对方一组灵摆刻度来灵摆召唤。那个场合，不是从额外卡组中不能把怪兽灵摆召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(1163)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_BOTH_SIDE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c31531170.pendcon)
	e1:SetOperation(c31531170.pendop)
	e1:SetValue(SUMMON_TYPE_PENDULUM)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc1:RegisterEffect(e1)
	tc1:RegisterFlagEffect(31531170,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,tc2:GetFieldID())
	tc2:RegisterFlagEffect(31531170,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,tc1:GetFieldID())
end
-- 额外灵摆召唤手续的判定条件：确认存在可灵摆召唤的额外怪兽，且对方灵摆区域右位卡与标记配对一致，刻度区间有效，且我方有足够的额外灵摆召唤区域。
function c31531170.pendcon(e,c,og)
	if c==nil then return true end
	local tp=e:GetOwnerPlayer()
	-- 取得当前玩家受到的所有额外灵摆召唤效果（EFFECT_EXTRA_PENDULUM_SUMMON）列表，用于后续判断是否已有其他同类召唤手续。
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
	-- 如果本回合已经使用过本卡的额外灵摆召唤手续，且场上没有其他额外灵摆召唤效果，则不能再使用该灵摆召唤手续，判定失败。
	if aux.PendulumChecklist&(0x1<<tp)~=0 and #eset==0 then return false end
	-- 获取对方灵摆区域右位（序号1）的卡，作为一组灵摆刻度的右刻度来源。
	local rpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
	if rpz==nil or rpz:GetFieldID()~=c:GetFlagEffectLabel(31531170) then return false end
	local lscale=c:GetLeftScale()
	local rscale=rpz:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	-- 计算我方额外卡组的灵摆怪兽能够特殊召唤到的可用区域数量（针对额外灵摆召唤的空位限制）。
	local ft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	if ft<=0 then return false end
	if og then
		-- 当存在候选组 og 时，检查其中是否有至少1只怪兽满足灵摆召唤条件（刻度区间内、可灵摆召唤，且满足其他限制）。
		return og:IsExists(aux.PConditionFilter,1,nil,e,tp,lscale,rscale,eset)
	else
		-- 当没有指定候选组时，检查我方额外卡组表侧表示中是否存在至少1只满足该刻度区间且可灵摆召唤的灵摆怪兽。
		return Duel.IsExistingMatchingCard(aux.PConditionFilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lscale,rscale,eset)
	end
end
-- 执行额外灵摆召唤：根据可用数量和限制，选择要灵摆召唤的怪兽；若选择了其他额外灵摆召唤效果则消耗其使用次数，否则在本回合标记中记入已使用本卡手续；将选择的怪兽加入灵摆召唤组并展示作为刻度的两张卡。
function c31531170.pendop(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
	local tp=e:GetOwnerPlayer()
	-- 取得当前玩家可用的额外灵摆召唤效果列表，用于选择使用哪一个效果进行灵摆召唤。
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
	-- 获取对方灵摆区域右位的卡，作为一组灵摆刻度的右刻度来源。
	local rpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
	local lscale=c:GetLeftScale()
	local rscale=rpz:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	-- 计算可特殊召唤的额外灵摆怪兽可用区域数量，即本次最多能灵摆召唤的数量上限（未考虑其他限制时）。
	local ft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 若场上有“召唤之门”效果适用，则获取其记录的每回合从额外卡组特殊召唤的剩余次数上限 c29724053[tp]，用于限制本次灵摆召唤数量。
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	if ect~=nil then ft=math.min(ft,ect) end
	local tg=nil
	if og then
		-- 从候选组 og 中筛选出位于额外卡组且满足灵摆召唤条件的怪兽，作为可召唤目标组。
		tg=og:Filter(Card.IsLocation,nil,LOCATION_EXTRA):Filter(aux.PConditionFilter,nil,e,tp,lscale,rscale,eset)
	else
		-- 没有指定候选组时，从额外卡组中筛选所有满足灵摆召唤条件且可灵摆召唤的怪兽作为目标组。
		tg=Duel.GetMatchingGroup(aux.PConditionFilter,tp,LOCATION_EXTRA,0,nil,e,tp,lscale,rscale,eset)
	end
	local ce=nil
	-- 判断当前玩家本回合是否尚未使用过“共鸣的振动”的额外灵摆召唤手续，b1 为真表示未使用。
	local b1=aux.PendulumChecklist&(0x1<<tp)==0
	local b2=#eset>0
	if b1 and b2 then
		local options={1163}
		for _,te in ipairs(eset) do
			table.insert(options,te:GetDescription())
		end
		-- 当本效果和另一个额外灵摆召唤效果都可用时，让玩家选择使用哪一个额外灵摆召唤效果。
		local op=Duel.SelectOption(tp,table.unpack(options))
		if op>0 then
			ce=eset[op]
		end
	elseif b2 and not b1 then
		local options={}
		for _,te in ipairs(eset) do
			table.insert(options,te:GetDescription())
		end
		-- 当本回合已使用过本卡效果但存在其他额外灵摆召唤效果时，让玩家选择要使用的那个额外灵摆召唤效果。
		local op=Duel.SelectOption(tp,table.unpack(options))
		ce=eset[op+1]
	end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示，并准备进入灵摆怪兽选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从目标组 tg 中选择最多 ft 张满足特定额外灵摆召唤过滤条件的怪兽，作为本次灵摆召唤的素材。
	local g=tg:FilterSelect(tp,aux.PConditionExtraFilterSpecific,0,ft,nil,e,tp,lscale,rscale,ce)
	if #g==0 then return end
	if ce then
		-- 向双方展示所选择的额外灵摆召唤效果对应原卡的卡图动画，提示效果来源。
		Duel.Hint(HINT_CARD,0,ce:GetOwner():GetOriginalCode())
		ce:UseCountLimit(tp)
	else
		-- 将当前玩家标记为已使用过本卡的额外灵摆召唤手续，防止本回合再次使用（将对应玩家位写入 aux.PendulumChecklist）。
		aux.PendulumChecklist=aux.PendulumChecklist|(0x1<<tp)
	end
	-- 展示本卡（共鸣的振动）的卡图，作为本次灵摆召唤手续的动画提示。
	Duel.Hint(HINT_CARD,0,31531170)
	sg:Merge(g)
	-- 显示左刻度卡（作为一组刻度的己方灵摆刻度卡）被选中的动画，并记录该卡与本次召唤相关。
	Duel.HintSelection(Group.FromCards(c))
	-- 显示右刻度卡（对方灵摆区域右位卡）被选中的动画，并记录该卡与本次召唤相关。
	Duel.HintSelection(Group.FromCards(rpz))
end
