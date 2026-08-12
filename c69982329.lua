--ペンデュラム・ターン
-- 效果：
-- ①：以自己或者对方的灵摆区域1张卡为对象，宣言1～10的灵摆刻度才能发动。这个回合，那张卡变成宣言的灵摆刻度。
function c69982329.initial_effect(c)
	-- ①：以自己或者对方的灵摆区域1张卡为对象，宣言1～10的灵摆刻度才能发动。这个回合，那张卡变成宣言的灵摆刻度。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c69982329.target)
	e1:SetOperation(c69982329.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的对象选择与刻度宣言处理
function c69982329.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) end
	-- 检查双方的灵摆区域是否存在可以作为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil) end
	-- 提示玩家选择作为效果对象的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择双方灵摆区域的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_PZONE,LOCATION_PZONE,1,1,nil)
	local tc=g:GetFirst()
	local t={}
	local p=1
	for i=1,10 do
		if i~=tc:GetLeftScale() then
			t[p]=i
			p=p+1
		end
	end
	-- 让发动效果的玩家宣言一个合法的灵摆刻度数值
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	e:SetLabel(ac)
end
-- 效果处理，使作为对象的卡在回合结束前变成宣言的灵摆刻度
function c69982329.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那张卡变成宣言的灵摆刻度。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		tc:RegisterEffect(e2)
	end
end
