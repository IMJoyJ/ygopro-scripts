--レッドアイズ・トランスマイグレーション
-- 效果：
-- 「真红王」的降临必需。
-- ①：从自己的手卡·场上把等级合计直到8以上的怪兽解放或者作为解放的代替而把自己墓地的「真红眼」怪兽除外，从手卡把「真红王」仪式召唤。
function c45410988.initial_effect(c)
	-- 为卡片添加仪式召唤效果，允许使用等级总和超过仪式怪兽原本等级的素材进行召唤，且素材需满足mfilter条件
	aux.AddRitualProcGreaterCode(c,19025379,nil,c45410988.mfilter)
end
-- 过滤函数，用于判断怪兽是否为「真红眼」系列
function c45410988.mfilter(c)
	return c:IsSetCard(0x3b)
end
