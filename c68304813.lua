--冥界の宝札
-- 效果：
-- ①：自己作把怪兽2只以上解放的上级召唤成功的场合发动。自己从卡组抽2张。
function c68304813.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己作把怪兽2只以上解放的上级召唤成功的场合发动。自己从卡组抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68304813,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c68304813.condition)
	e2:SetTarget(c68304813.target)
	e2:SetOperation(c68304813.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_MSET)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 把怪兽2只以上解放
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c68304813.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 检查上级召唤（或里侧表示上级召唤）时解放的怪兽是否在2只以上，并将结果以Label形式传递给对应的触发效果
function c68304813.valcheck(e,c)
	if c:GetMaterial():IsExists(Card.IsType,2,nil,TYPE_MONSTER) then
		e:GetLabelObject():SetLabel(1)
		e:GetLabelObject():GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
		e:GetLabelObject():GetLabelObject():SetLabel(0)
	end
end
-- 判断触发条件：上级召唤成功的怪兽由自己召唤，且解放的怪兽数量在2只以上
function c68304813.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsSummonType(SUMMON_TYPE_ADVANCE) and tc:IsSummonPlayer(tp) and e:GetLabel()==1
end
-- 设置抽卡效果的发动目标和操作信息
function c68304813.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为2（抽卡张数）
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为：玩家自己从卡组抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 执行抽卡效果的处理
function c68304813.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果从卡组抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
