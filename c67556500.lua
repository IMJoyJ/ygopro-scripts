--波動竜フォノン・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡同调召唤成功时，宣言1～3的等级才能发动。这张卡的等级变成宣言的等级。这个效果发动过的回合，自己不能作以这张卡为同调素材的同调召唤以外的特殊召唤。自己对「波动龙 声子龙」1回合只能有1次特殊召唤。
function c67556500.initial_effect(c)
	c:SetSPSummonOnce(67556500)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡同调召唤成功时，宣言1～3的等级才能发动。这张卡的等级变成宣言的等级。这个效果发动过的回合，自己不能作以这张卡为同调素材的同调召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67556500,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c67556500.lvcon)
	e1:SetTarget(c67556500.lvtg)
	e1:SetOperation(c67556500.lvop)
	c:RegisterEffect(e1)
end
-- 设置效果发动条件：这张卡同调召唤成功时
function c67556500.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置效果发动阶段的处理：让玩家宣言1～3的等级并记录
function c67556500.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 发送提示信息，提示玩家宣言等级
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	-- 让玩家宣言1～3的等级并返回该数值
	local lv=Duel.AnnounceLevel(tp,1,3)
	e:SetLabel(lv)
end
-- 设置效果处理阶段的处理：变更等级，并注册本回合的特殊召唤限制
function c67556500.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=0
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的等级变成宣言的等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		fid=c:GetRealFieldID()
	end
	-- 这个效果发动过的回合，自己不能作以这张卡为同调素材的同调召唤以外的特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTarget(c67556500.splimit)
	e2:SetLabel(fid)
	-- 将特殊召唤限制效果注册给玩家
	Duel.RegisterEffect(e2,tp)
	-- 这个效果发动过的回合，自己不能作以这张卡为同调素材的同调召唤以外的特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_MUST_BE_SMATERIAL)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e3)
end
-- 特殊召唤限制的过滤函数：限制非同调召唤，或者同调召唤但未使用这张卡作为素材
function c67556500.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return sumtype~=SUMMON_TYPE_SYNCHRO or e:GetOwner():GetRealFieldID()~=e:GetLabel() or e:GetOwner():IsFacedown()
end
