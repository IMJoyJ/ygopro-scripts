--禁断儀式術
-- 效果：
-- （注：暂时无法正常使用）
-- 
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己墓地的怪兽除外，从自己墓地把1只仪式怪兽仪式召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
-- ②：把墓地的这张卡除外才能发动。这个回合，自己仪式召唤的场合只有1次，自己墓地的仪式怪兽也能作为解放的代替而除外。
local s,id,o=GetID()
-- 初始化效果函数
function s.initial_effect(c)
	-- 为卡片添加仪式召唤效果，条件为墓地中的怪兽等级总和等于仪式怪兽等级
	local e1=aux.AddRitualProcEqual2(c,aux.TRUE,LOCATION_GRAVE,aux.TRUE,aux.FALSE,false,s.extraop)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。这个回合，自己仪式召唤的场合只有1次，自己墓地的仪式怪兽也能作为解放的代替而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+o)
	-- 设置效果发动的费用为将此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.rlop)
	c:RegisterEffect(e2)
	if not s.globle_check then
		s.globle_check=true
		-- 保存原Duel.ReleaseRitualMaterial函数的引用
		Ritual_ReleaseRitualMaterial=Duel.ReleaseRitualMaterial
		-- 重写Duel.ReleaseRitualMaterial函数，用于处理仪式召唤时的特殊处理
		Duel.ReleaseRitualMaterial=function(mat)
			-- 判断是否满足条件：素材中存在满足条件的仪式怪兽且当前玩家有对应标识效果
			if mat:IsExists(s.rlfilter,1,nil,0) and Duel.GetFlagEffect(0,id)~=0 then
				-- 为玩家0注册一个标识效果，用于标记该玩家已使用过②效果
				Duel.RegisterFlagEffect(0,id+o,RESET_PHASE+PHASE_END,0,1)
			end
			-- 判断是否满足条件：素材中存在满足条件的仪式怪兽且当前玩家有对应标识效果
			if mat:IsExists(s.rlfilter,1,nil,1) and Duel.GetFlagEffect(1,id)~=0 then
				-- 为玩家1注册一个标识效果，用于标记该玩家已使用过②效果
				Duel.RegisterFlagEffect(1,id+o,RESET_PHASE+PHASE_END,0,1)
			end
			Ritual_ReleaseRitualMaterial(mat)
		end
	end
end
-- 定义过滤函数，用于判断卡片是否为墓地中的仪式怪兽
function s.rlfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER)
		and c:IsControler(tp)
end
-- 定义额外处理函数，用于处理仪式召唤后特殊召唤怪兽的破坏效果
function s.extraop(e,tp,eg,ep,ev,re,r,rp,tc,mat)
	if not tc then return end
	local fid=e:GetHandler():GetFieldID()
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己墓地的怪兽除外，从自己墓地把1只仪式怪兽仪式召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetLabel(fid)
	e1:SetLabelObject(tc)
	e1:SetCondition(s.descon)
	e1:SetOperation(s.desop)
	-- 将效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 定义破坏条件函数，用于判断是否满足破坏条件
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 定义破坏操作函数，用于执行破坏操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，显示该卡被破坏
	Duel.Hint(HINT_CARD,0,id)
	-- 将目标怪兽以效果原因破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
-- 定义②效果的处理函数
function s.rlop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该玩家是否已使用过②效果
	if Duel.GetFlagEffect(tp,id)==0 then
		-- ②：把墓地的这张卡除外才能发动。这个回合，自己仪式召唤的场合只有1次，自己墓地的仪式怪兽也能作为解放的代替而除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
		e1:SetTargetRange(LOCATION_GRAVE,0)
		e1:SetCondition(s.rlcon)
		e1:SetTarget(s.rltg)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到场上
		Duel.RegisterEffect(e1,tp)
	end
	-- 为当前玩家注册一个标识效果，标记该回合已使用过②效果
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 定义条件函数，用于判断是否满足②效果的触发条件
function s.rlcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家是否已使用过②效果
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>Duel.GetFlagEffect(e:GetHandlerPlayer(),id+o)
end
-- 定义目标函数，用于筛选可作为仪式素材的怪兽
function s.rltg(e,c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER)
end
