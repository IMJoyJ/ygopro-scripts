--完全なる世界 トゥーン・ワールド
-- 效果：
-- 这个卡名的②的效果1回合可以使用最多3次。
-- ①：这张卡只要在场地区域存在，卡名当作「卡通世界」使用。
-- ②：1回合1次，自己主要阶段才能发动。把1张「卡通」卡或者有那卡名记述的卡从卡组加入手卡。
-- ③：其他卡发动的效果适用之际，可以把自己场上1只卡通怪兽直到那个效果处理后除外（这个回合，这个卡名的这个效果不能把原本卡名相同的怪兽除外）。
local s,id,o=GetID()
-- 完全なる世界 トゥーン・ワールド
function s.initial_effect(c)
	-- 这张卡只要在场地区域存在，卡名当作「卡通世界」使用
	aux.EnableChangeCode(c,15259703,LOCATION_FZONE)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。把1张「卡通」卡或者有那卡名记述的卡从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：其他卡发动的效果适用之际，可以把自己场上1只卡通怪兽直到那个效果处理后除外（这个回合，这个卡名的这个效果不能把原本卡名相同的怪兽除外）。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetLabel(id)
	e3:SetCondition(s.rmcon)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
-- 筛选「卡通」卡或有其记述的卡的过滤函数
function s.thfilter(c)
	-- 检查是否为「卡通」卡、或记述了「卡通」系列、或记述了「卡通世界」
	return (c:IsSetCard(0x62) or aux.IsSetNameMonsterListed(c,0x62) or aux.IsCodeListed(c,15259703))
		and c:IsAbleToHand()
end
-- 效果②的发动条件与标记检测
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在可检索卡且本回合发动次数小于3次
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetFlagEffect(tp,id)<3 end
	-- 注册效果②在本回合的使用次数标记
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组检索卡片并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择1张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 把选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果③的触发条件：其他卡发动的效果适用之际且场上有卡通怪兽
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler()
		-- 检查场上是否存在可以除外的卡通怪兽
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 筛选场上表侧表示且可除外的卡通怪兽
function s.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove() and c:IsType(TYPE_TOON)
end
-- 效果③的处理：选择并暂时除外1只卡通怪兽，效果处理后返回场上，并限制本回合同名怪兽不能再以此效果除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 询问玩家是否发动效果将怪兽除外
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,3)) then  --"是否把怪兽除外？"
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家选择1只符合条件的卡通怪兽
		local tg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
		-- 显示卡片发动提示
		Duel.Hint(HINT_CARD,0,id)
		-- 显示选择的目标怪兽
		Duel.HintSelection(tg)
		local rc=tg:GetFirst()
		-- 将目标怪兽暂时除外
		if Duel.Remove(rc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			-- 直到那个效果处理后除外
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_CHAIN_SOLVED)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(rc)
			e1:SetCountLimit(1)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			-- 注册效果处理完后让怪兽返回场上的延迟效果
			Duel.RegisterEffect(e1,tp)
			-- （这个回合，这个卡名的这个效果不能把原本卡名相同的怪兽除外）。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetCode(EFFECT_CANNOT_REMOVE)
			e2:SetTargetRange(1,0)
			e2:SetTarget(s.rmlimit)
			e2:SetLabel(rc:GetOriginalCode())
			e2:SetReset(RESET_PHASE+PHASE_END)
			-- 注册限制本回合同原本卡名怪兽不能再被除外的玩家效果
			Duel.RegisterEffect(e2,tp)
		end
	end
end
-- 限制该原本卡名的怪兽本回合不能再被此效果除外
function s.rmlimit(e,c,tp,r,re)
	return c:GetOriginalCode()==e:GetLabel() and re and re:GetLabel()==id and r&REASON_EFFECT~=0
end
-- 检查被除外怪兽的标记效果是否存在
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)~=0
end
-- 将暂时除外的怪兽返回场上
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 把被除外的怪兽以原本表示形式返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
