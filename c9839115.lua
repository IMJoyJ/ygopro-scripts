--月朧龍ヴァグナワ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。这张卡的攻击力直到下个回合的结束时上升那些作为同调素材的除调整以外的怪兽的等级合计×300。那之后，给与对方那只作为同调素材的调整的等级×300伤害。
local s,id,o=GetID()
-- 注册卡片效果，包括同调召唤手续、苏生限制、同调召唤成功时的诱发效果以及用于记录同调素材等级的素材检查效果
function s.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的效果1回合只能使用1次。①：这张卡同调召唤的场合才能发动。这张卡的攻击力直到下个回合的结束时上升那些作为同调素材的除调整以外的怪兽的等级合计×300。那之后，给与对方那只作为同调素材的调整的等级×300伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.adcon)
	e1:SetTarget(s.adtg)
	e1:SetOperation(s.adop)
	c:RegisterEffect(e1)
	-- 上升那些作为同调素材的除调整以外的怪兽的等级合计×300。那之后，给与对方那只作为同调素材的调整的等级×300伤害。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	e0:SetLabelObject(e1)
	c:RegisterEffect(e0)
end
-- 素材检查函数：获取同调素材中调整怪兽的等级，并计算非调整怪兽的等级合计，将这两个数值保存到效果e1中
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local mg=g:Filter(Card.IsTuner,nil,c)
	local tc=mg:GetFirst()
	if not tc then
		e:GetLabelObject():SetLabel(0)
		return
	end
	if #mg>1 then
		local tg=g-(g:Filter(Card.IsNotTuner,nil,c))
		if #tg>0 then
			tc=tg:GetFirst()
		end
	end
	local lv=tc:GetSynchroLevel(c)
	local lv2=lv>>16
	lv=lv&0xffff
	if lv2>0 and not g:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),#g,#g,c) then
		lv=lv2
	end
	if tc:IsHasEffect(89818984) and not g:CheckWithSumEqual(Card.GetSynchroLevel,c:GetLevel(),#g,#g,c) then
		lv=2
	end
	e:GetLabelObject():SetLabel(lv,c:GetLevel()-lv)
end
-- 发动条件：这张卡同调召唤成功
function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果靶向：获取保存的素材等级信息，并设置给与对方伤害的操作信息
function s.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dam,atk=e:GetLabel()
	if chk==0 then return atk>0 and dam>0 end
	-- 设置操作信息：给与对方相当于作为同调素材的调整怪兽等级×300的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam*300)
end
-- 效果处理：使这张卡的攻击力直到下个回合结束时上升，那之后给与对方伤害
function s.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dam,atk=e:GetLabel()
	if not c:IsRelateToChain() or c:IsFacedown() then return end
	-- 这张卡的攻击力直到下个回合的结束时上升那些作为同调素材的除调整以外的怪兽的等级合计×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
	e1:SetValue(atk*300)
	c:RegisterEffect(e1)
	-- 中断当前效果处理，使之后的伤害处理与攻击力上升不视为同时处理
	Duel.BreakEffect()
	-- 给与对方相当于作为同调素材的调整怪兽等级×300的伤害
	Duel.Damage(1-tp,dam*300,REASON_EFFECT)
end
