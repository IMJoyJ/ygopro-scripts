--禁断儀式術
-- 效果：
-- （注：暂时无法正常使用）
-- 
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己墓地的怪兽除外，从自己墓地把1只仪式怪兽仪式召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
-- ②：把墓地的这张卡除外才能发动。这个回合，自己仪式召唤的场合只有1次，自己墓地的仪式怪兽也能作为解放的代替而除外。
local s,id,o=GetID()
-- 初始化卡片效果，定义仪式召唤处理和快速效果。
function s.initial_effect(c)
	-- 使用aux.AddRitualProcEqual2函数为当前卡添加仪式召唤的处理流程。该函数用于设置仪式召唤的条件，包括墓地怪兽数量、等级匹配等。s.extraop是回调函数，用于在满足仪式召唤条件后执行的操作。
	local e1=aux.AddRitualProcEqual2(c,aux.TRUE,LOCATION_GRAVE,aux.TRUE,aux.FALSE,false,s.extraop)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 创建并注册一个快速效果e2，用于增加墓地的仪式素材。这个效果可以在自由连锁发动，并且作用范围限定在墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"增加墓地仪式素材"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+o)
	-- 设置效果的cost，使用aux.bfgcost函数定义将这张卡从场上移除作为cost的条件。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.rlop)
	c:RegisterEffect(e2)
	if not s.globle_check then
		s.globle_check=true
		-- 备份原始的Duel.ReleaseRitualMaterial函数，以便后续恢复。
		Ritual_ReleaseRitualMaterial=Duel.ReleaseRitualMaterial
		-- 重写Duel.ReleaseRitualMaterial函数，用于自定义仪式素材的处理逻辑。
		Duel.ReleaseRitualMaterial=function(mat)
			-- 检查墓地是否存在符合条件的仪式怪兽（s.rlfilter），并且玩家0的id标识效果不为0。如果条件满足，则注册一个flag效果，用于标记该玩家已经使用了该效果。
			if mat:IsExists(s.rlfilter,1,nil,0) and Duel.GetFlagEffect(0,id)~=0 then
				-- 为玩家0注册一个全局环境下的标识效果，用于记录是否使用过效果。RESET_PHASE+PHASE_END表示在阶段结束时重置该标识。
				Duel.RegisterFlagEffect(0,id+o,RESET_PHASE+PHASE_END,0,1)
			end
			-- 检查墓地是否存在符合条件的仪式怪兽（s.rlfilter），并且玩家1的id标识效果不为0。如果条件满足，则注册一个flag效果，用于标记该玩家已经使用了该效果。
			if mat:IsExists(s.rlfilter,1,nil,1) and Duel.GetFlagEffect(1,id)~=0 then
				-- 为玩家1注册一个全局环境下的标识效果，用于记录是否使用过效果。RESET_PHASE+PHASE_END表示在阶段结束时重置该标识。
				Duel.RegisterFlagEffect(1,id+o,RESET_PHASE+PHASE_END,0,1)
			end
			Ritual_ReleaseRitualMaterial(mat)
		end
	end
end
-- 定义一个过滤器函数s.rlfilter，用于判断卡片是否是墓地的仪式怪兽并且属于当前玩家。
function s.rlfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER)
		and c:IsControler(tp)
end
-- 定义extraop函数，用于处理仪式召唤后的效果。它会为目标怪兽注册一个flag效果，并在结束阶段销毁该怪兽。
function s.extraop(e,tp,eg,ep,ev,re,r,rp,tc,mat)
	if not tc then return end
	local fid=e:GetHandler():GetFieldID()
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	-- 在仪式召唤成功后，为目标怪兽tc注册一个Flag Effect，记录其Field ID，并创建一个持续性的Field Effect e1，在结束阶段检查Flag Effect的Label是否一致，如果不一致则重置Effect并返回false，否则返回true。这个过程用于确保只有被正确标记的怪兽才会被销毁。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetLabel(fid)
	e1:SetLabelObject(tc)
	e1:SetCondition(s.descon)
	e1:SetOperation(s.desop)
	-- 将e1注册为tp玩家的效果。
	Duel.RegisterEffect(e1,tp)
end
-- 定义一个条件函数s.descon，用于判断目标怪兽是否仍然有效。如果目标怪兽的Flag Effect Label与e1的Label不一致，则重置Effect并返回false；否则返回true。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 定义一个操作函数s.desop，用于在结束阶段销毁目标怪兽。它会提示卡片信息，然后使用Duel.Destroy函数以效果为理由破坏目标怪兽。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家0发送HINT_CARD类型的提示，显示卡片id。
	Duel.Hint(HINT_CARD,0,id)
	-- 以REASON_EFFECT的原因破坏e:GetLabelObject()，即被标记的仪式怪兽。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
-- 定义rlop函数，用于处理增加墓地仪式素材的效果。它会检查玩家是否已经使用了该效果，如果未使用则注册一个Field Effect e1，用于在墓地中选择仪式怪兽作为祭品。
function s.rlop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果当前回合玩家tp还没有使用过这个效果（Duel.GetFlagEffect(tp,id)==0），则执行后续代码。
	if Duel.GetFlagEffect(tp,id)==0 then
		-- 创建并注册一个Field Effect e1，用于允许从墓地中选择仪式怪兽作为祭品。该效果的条件是s.rlcon，目标是s.rltg，值为1，并且在阶段结束时重置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
		e1:SetTargetRange(LOCATION_GRAVE,0)
		e1:SetCondition(s.rlcon)
		e1:SetTarget(s.rltg)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将e1注册为tp玩家的效果。
		Duel.RegisterEffect(e1,tp)
	end
	-- 为当前回合的玩家注册一个全局标识效果，用于记录是否使用了该效果。RESET_PHASE+PHASE_END表示在阶段结束时重置该标识。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 定义条件函数s.rlcon，用于判断是否可以从墓地中选择仪式怪兽作为祭品。它会比较玩家的id标识效果和id+o标识效果的值。
function s.rlcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回一个布尔值，表示当前回合玩家tp已经使用的效果数量是否大于id+o标识的效果数量。
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>Duel.GetFlagEffect(e:GetHandlerPlayer(),id+o)
end
-- 定义目标函数s.rltg，用于判断卡片是否是仪式怪兽。它会检查卡片的类型是否包含TYPE_RITUAL和TYPE_MONSTER。
function s.rltg(e,c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER)
end
