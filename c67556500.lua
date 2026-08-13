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
-- 发动条件：这张卡是同调召唤成功的场合
function c67556500.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果目标处理：无需检查即可发动，让玩家宣言1～3的等级并记录到标签中
function c67556500.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向自己玩家显示宣言等级的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让自己宣言1～3中的1个等级
	local lv=Duel.AnnounceLevel(tp,1,3)
	e:SetLabel(lv)
end
-- 效果处理：这张卡在场上表侧表示且仍与效果关联时将其等级变为宣言的等级，随后注册本回合对自己的特殊召唤限制效果以及这张卡必须作为同调素材的效果
function c67556500.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=0
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的等级变成宣言的等级
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		fid=c:GetRealFieldID()
	end
	-- 这个效果发动过的回合，自己不能作以这张卡为同调素材的同调召唤以外的特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTarget(c67556500.splimit)
	e2:SetLabel(fid)
	-- 把不能特殊召唤的限制效果作为自己玩家的效果注册到全局环境（直到回合结束）
	Duel.RegisterEffect(e2,tp)
	-- 自己不能作以这张卡为同调素材的同调召唤以外的特殊召唤（即这张卡必须作为同调素材）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_MUST_BE_SMATERIAL)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e3)
end
-- 特殊召唤限制过滤函数：不是同调召唤、或不是以这张卡（FieldID不一致）为素材、或这张卡已变成里侧表示的场合，禁止那次特殊召唤
function c67556500.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return sumtype~=SUMMON_TYPE_SYNCHRO or e:GetOwner():GetRealFieldID()~=e:GetLabel() or e:GetOwner():IsFacedown()
end
