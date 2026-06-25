--完全なる世界 トゥーン・ワールド
local s,id,o=GetID()
-- 注册卡片效果的初始化函数（在规则上视为「卡通世界」，包含允许发动卡片的效果，一回合最多可以使用3次的检索效果，以及在其他卡效果适用时暂时除外场上卡通怪兽的效果）
function s.initial_effect(c)
	-- 使此卡在场地区域存在时卡名变更为「卡通世界」
	aux.EnableChangeCode(c,15259703,LOCATION_FZONE)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的②效果一回合最多可以使用3次。自己主要阶段才能发动。从卡组将1张「卡通」卡或其卡名记述的卡加入手牌
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 其他卡的效果适用时，可以作为代替将自己场上的1只卡通怪兽暂时除外
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetCondition(s.rmcon)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中满足属于「卡通」系列、或记述了「卡通」怪兽卡名、或记述了「卡通世界」卡名，且能加入手牌的卡片的过滤函数
function s.thfilter(c)
	-- 检查卡片是否属于「卡通」系列，或者其文本中记述了「卡通」怪兽卡名，或者记述了「卡通世界」卡名
	return (c:IsSetCard(0x62) or aux.IsSetNameMonsterListed(c,0x62) or aux.IsCodeListed(c,15259703))
		and c:IsAbleToHand()
end
-- 效果②检索效果的发动准备与检查函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，检查卡组是否存在可检索的卡，且当前回合玩家发动该效果的次数是否小于3次
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetFlagEffect(tp,id)<3 end
	-- 为玩家注册全局标识，用于记录本回合使用该效果的次数
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	-- 设置效果处理的分类为加入手牌，数量为1，目标位置为卡组
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②检索效果的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果③暂时除外以代替效果适用的发动条件函数
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler()
		-- 并且检查自己场上是否存在满足条件的卡通怪兽
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤自己场上可被除外的表侧表示卡通怪兽的过滤函数
function s.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove() and c:IsType(TYPE_TOON)
end
-- 效果③暂时除外代替处理的处理函数
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 询问玩家是否发动该效果作为代替
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,3)) then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家选择自己场上1只卡通怪兽
		local tg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
		-- 向双方玩家展示此卡发动的动画
		Duel.Hint(HINT_CARD,0,id)
		-- 在场上显式标出被选为除外对象的怪兽
		Duel.HintSelection(tg)
		local rc=tg:GetFirst()
		-- 如果将该怪兽以效果以及暂时除外原因成功除外
		if Duel.Remove(rc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			-- 直到该效果处理结束时为止，被除外的怪兽返回场上
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_CHAIN_SOLVED)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(rc)
			e1:SetCountLimit(1)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			-- 在全局注册该连锁处理结束时将怪兽返回场上的临时效果
			Duel.RegisterEffect(e1,tp)
			-- 此回合，不能以该效果将此卡名原卡名相同的怪兽除外
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetCode(EFFECT_CANNOT_REMOVE)
			e2:SetTargetRange(1,0)
			e2:SetTarget(s.rmlimit)
			e2:SetLabel(rc:GetOriginalCode())
			e2:SetReset(RESET_PHASE+PHASE_END)
			-- 在全局注册限制同名怪兽此回合不能再以此效果除外的效果
			Duel.RegisterEffect(e2,tp)
		end
	end
end
-- 限制不能重复除外相同原卡名怪兽的过滤函数
function s.rmlimit(e,c,tp,r,re)
	return c:GetOriginalCode()==e:GetLabel() and re and re:GetHandler():GetOriginalCode()==id and r&REASON_EFFECT~=0
end
-- 判断被暂时除外的怪兽是否带有标识以决定是否返回场面的条件函数
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)~=0
end
-- 被暂时除外的怪兽返回场面的处理函数
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将暂时除外的怪兽返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
