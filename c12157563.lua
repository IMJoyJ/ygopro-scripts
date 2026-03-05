--禁断儀式術
-- 效果：
-- （注：暂时无法正常使用）
-- 
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己墓地的怪兽除外，从自己墓地把1只仪式怪兽仪式召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
-- ②：把墓地的这张卡除外才能发动。这个回合，自己仪式召唤的场合只有1次，自己墓地的仪式怪兽也能作为解放的代替而除外。
local s,id,o=GetID()
-- 注册仪式召唤效果和墓地仪式素材增加效果
function s.initial_effect(c)
	-- 添加等级合计等于仪式怪兽等级的仪式召唤效果
	local e1=aux.AddRitualProcEqual2(c,aux.TRUE,LOCATION_GRAVE,aux.TRUE,aux.FALSE,false,s.extraop)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。这个回合，自己仪式召唤的场合只有1次，自己墓地的仪式怪兽也能作为解放的代替而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"增加墓地仪式素材"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+o)
	-- 支付将此卡除外的费用
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.rlop)
	c:RegisterEffect(e2)
	if not s.globle_check then
		s.globle_check=true
		-- 保存原Duel.ReleaseRitualMaterial函数
		Ritual_ReleaseRitualMaterial=Duel.ReleaseRitualMaterial
		-- 重写Duel.ReleaseRitualMaterial函数以添加额外逻辑
		Duel.ReleaseRitualMaterial=function(mat)
			-- 判断是否有玩家在使用仪式素材时使用了墓地仪式怪兽
			if mat:IsExists(s.rlfilter,1,nil,0) and Duel.GetFlagEffect(0,id)~=0 then
				-- 为玩家0注册一个标识效果，用于标记仪式召唤使用了墓地仪式怪兽
				Duel.RegisterFlagEffect(0,id+o,RESET_PHASE+PHASE_END,0,1)
			end
			-- 判断是否有玩家在使用仪式素材时使用了墓地仪式怪兽
			if mat:IsExists(s.rlfilter,1,nil,1) and Duel.GetFlagEffect(1,id)~=0 then
				-- 为玩家1注册一个标识效果，用于标记仪式召唤使用了墓地仪式怪兽
				Duel.RegisterFlagEffect(1,id+o,RESET_PHASE+PHASE_END,0,1)
			end
			Ritual_ReleaseRitualMaterial(mat)
		end
	end
end
-- 判断卡片是否为墓地的仪式怪兽
function s.rlfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER)
		and c:IsControler(tp)
end
-- 处理仪式召唤后在结束阶段破坏特殊召唤的怪兽
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
	-- 将效果注册到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否为当前仪式召唤的怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 破坏在结束阶段特殊召唤的仪式怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示破坏仪式怪兽的动画
	Duel.Hint(HINT_CARD,0,id)
	-- 以效果原因破坏目标怪兽
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
-- ②：把墓地的这张卡除外才能发动。这个回合，自己仪式召唤的场合只有1次，自己墓地的仪式怪兽也能作为解放的代替而除外。
function s.rlop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否已使用过此效果
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
		-- 将效果注册到玩家
		Duel.RegisterEffect(e1,tp)
	end
	-- 为玩家注册一个标识效果，标记此效果已使用
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否已使用过此效果
function s.rlcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否已使用过此效果
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>Duel.GetFlagEffect(e:GetHandlerPlayer(),id+o)
end
-- 设置仪式召唤时可使用的墓地仪式怪兽条件
function s.rltg(e,c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER)
end
