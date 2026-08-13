--ゾルガ
-- 效果：
-- ①：这张卡为上级召唤而被解放的场合发动。自己回复2000基本分。
function c16268841.initial_effect(c)
	-- ①：这张卡为上级召唤而被解放的场合发动。自己回复2000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16268841,0))  --"回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_RELEASE)
	e1:SetCondition(c16268841.reccon)
	e1:SetTarget(c16268841.rectg)
	e1:SetOperation(c16268841.recop)
	c:RegisterEffect(e1)
end
-- 发动条件判定：检测这张卡是否因“上级召唤”而被解放，即解放原因是否为召唤（REASON_SUMMON），同时将解放前的控制者记录到效果标签中，以便后续把LP回复给对应的玩家。
function c16268841.reccon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():IsReason(REASON_SUMMON)
end
-- 效果发动时的目标处理：在效果发动时确定并登记回复对象玩家为解放前控制者、回复数值为2000，同时向系统登记本次操作属于回复效果，供规则检测和时点判断使用。
function c16268841.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段，确认当前正处于上级召唤成功后的时点（或与其等效的怪兽放置成功时点），满足“为上级召唤而被解放的场合发动”的发动时机条件。
	if chk==0 then return Duel.CheckEvent(EVENT_SUMMON_SUCCESS) or Duel.CheckEvent(EVENT_MSET) end
	-- 将本次效果的对象玩家设置为该卡被解放前的控制者，即进行上级召唤的玩家，使回复效果作用于该玩家。
	Duel.SetTargetPlayer(e:GetLabel())
	-- 设定本次效果处理时回复的基本分数值为2000。
	Duel.SetTargetParam(2000)
	-- 向系统登记连锁处理信息：该操作为回复基本分效果，目标玩家为之前记录的控制者，回复量为2000，由于不涉及卡片对象，targets设为nil。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,e:GetLabel(),2000)
end
-- 效果处理操作：从连锁信息中取出发动时登记的目标玩家和回复数值，并执行基本分回复。
function c16268841.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前登记的目标玩家p和回复数值d，作为后续回复操作的参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p回复d点基本分，回复原因记为效果（REASON_EFFECT）。
	Duel.Recover(p,d,REASON_EFFECT)
end
